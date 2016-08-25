//
//  GBUrlIntentHandler.m
//  GrowthbeatCore
//
//  Created by 堀内 暢之 on 2015/03/08.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GBUrlIntentHandler.h"
#import <UIKit/UIKit.h>
#import "Growthbeat.h"
#import "GBUrlIntent.h"

@implementation GBUrlIntentHandler

- (BOOL) handleIntent:(GBIntent *)intent {

    if (intent.type != GBIntentTypeUrl) {
        return NO;
    }

    if (![intent isKindOfClass:[GBUrlIntent class]]) {
        return NO;
    }

    GBUrlIntent *urlIntent = (GBUrlIntent *)intent;

    NSURL *url = [NSURL URLWithString:urlIntent.url];
    return [[UIApplication sharedApplication] openURL:url];

}

@end
