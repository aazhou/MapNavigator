//
//  MapNavigator.m
//  FishSaying
//
//  Created by aazhou on 14-4-29.
//  Copyright (c) 2014年 joyotime. All rights reserved.
//

#import "MapNavigator.h"

#define kMapAppScheme       @[@"comgooglemaps://",@"iosamap://navi",@"baidumap://map/"]

#define kAppleMap           NSLocalizedString(@"Apple Map", nil)
#define kGoogleMap          NSLocalizedString(@"Google Map", nil)
#define kAMap               NSLocalizedString(@"AMap", nil)
#define kBaiduMap           NSLocalizedString(@"Baidu Map", nil)

@implementation MapNavigator
{
    CLLocation *_currentLocation;
    CLLocation *_toLocation;
}

+ (instancetype)sharedInstance {
    static MapNavigator *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MapNavigator alloc] init];
    });
    return _instance;
}

- (void)show:(NSString *)title currentLocation:(CLLocation *)currentLocation toLocation:(CLLocation *)toLocation {
    _currentLocation = currentLocation;
    _toLocation = toLocation;
    NSMutableArray *menuItems = [NSMutableArray arrayWithObject:kAppleMap];
    
    for (int i = 0; i < kMapAppScheme.count; i++) {
        NSString *scheme = [kMapAppScheme objectAtIndex:i];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scheme]]) {
            if (i == 0) {
                [menuItems addObject:kGoogleMap];
            }
            else if (i == 1) {
                [menuItems addObject:kAMap];
            }
            else {
                [menuItems addObject:kBaiduMap];
            }
        }
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = title;
    actionSheet.delegate = self;
    
    for (NSString *item in menuItems) {
        [actionSheet addButtonWithTitle:item];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:kAppleMap]) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:_toLocation.coordinate addressDictionary:nil]];
        
        toLocation.name = actionSheet.title;
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
    else if ([title isEqualToString:kGoogleMap]) {
        NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%.8f,%.8f&daddr=%.8f,%.8f&directionsmode=transit",
                            _currentLocation.coordinate.latitude,
                            _currentLocation.coordinate.longitude,
                            _toLocation.coordinate.latitude,
                            _toLocation.coordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }
    else if ([title isEqualToString:kAMap]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"iosamap://navi?sourceApplication=FishSaying&backScheme=fishsaying&lat=%.8f&lon=%.8f&dev=1&style=1",_toLocation.coordinate.latitude,_toLocation.coordinate.longitude]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if ([title isEqualToString:kBaiduMap]) {
        double baiduLat, baiduLng;
        bd_encrypt(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude, &baiduLat, &baiduLng);
        
        NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.8f,%.8f&destination=%.8f,%.8f&&mode=driving",baiduLat,baiduLng,_toLocation.coordinate.latitude,_toLocation.coordinate.longitude];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Baidu Location to Mars

const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
//火星转百度坐标
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon)
{
    double x = gg_lon, y = gg_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    *bd_lon = z * cos(theta) + 0.0065;
    *bd_lat = z * sin(theta) + 0.006;
}
//百度坐标转火星
void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon)
{
    double x = bd_lon - 0.0065, y = bd_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    *gg_lon = z * cos(theta);
    *gg_lat = z * sin(theta);
}

@end
