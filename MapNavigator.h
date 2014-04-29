//
//  MapNavigator.h
//  FishSaying
//
//  Created by aazhou on 14-4-29.
//  Copyright (c) 2014年 joyotime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapNavigator : NSObject<UIActionSheetDelegate>

+ (instancetype)sharedInstance;

- (void)show:(NSString *)title currentLocation:(CLLocation *)currentLocation toLocation:(CLLocation *)toLocation;

@end
