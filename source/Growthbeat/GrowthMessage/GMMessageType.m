//
//  GMMessageType.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/16.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMMessageType.h"

NSString *NSStringFromGMMessageType(GMMessageType messageType) {

    switch (messageType) {
        case GMMessageTypePlain:
            return @"plain";
        case GMMessageTypeImage:
            return @"image";
        case GMMessageTypeBanner:
            return @"banner";
        case GMMessageTypeSwipe:
            return @"swipe";
        case GMMessageTypeUnknown:
            return nil;
    }

}

GMMessageType GMMessageTypeFromNSString(NSString *messageTypeString) {

    if ([messageTypeString isEqualToString:@"plain"]) {
        return GMMessageTypePlain;
    }
    if ([messageTypeString isEqualToString:@"image"]) {
        return GMMessageTypeImage;
    }
    if ([messageTypeString isEqualToString:@"banner"]) {
        return GMMessageTypeBanner;
    }
    if ([messageTypeString isEqualToString:@"swipe"]) {
        return GMMessageTypeSwipe;
    }
    return GMMessageTypeUnknown;

}