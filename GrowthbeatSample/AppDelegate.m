//
//  AppDelegate.m
//  GrowthbeatSample
//
//  Created by Kataoka Naoyuki on 2014/08/10.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSString *applicationId = @"PIaD6TaVt7wvKwao";
    [[GrowthPush sharedInstance] initializeWithApplicationId:applicationId credentialId:@"oGlWkVPDWghnvU2qwscqvZqWMbB2kUpO" environment:kGrowthPushEnvironment];
    [[Growthbeat sharedInstance] addIntentHandler:[[GBCustomIntentHandler alloc] initWithBlock:^BOOL(GBCustomIntent *customIntent) {
        NSDictionary *extra = customIntent.extra;
        NSLog(@"extra: %@", extra);
        if([extra objectForKey:@"type"]) {
            [[GrowthPush sharedInstance] requestDeviceToken];
        }
        return YES;
    }]];
    [[GrowthLink sharedInstance] initializeWithApplicationId:@"PIaD6TaVt7wvKwao" credentialId:@"oGlWkVPDWghnvU2qwscqvZqWMbB2kUpO"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        GBClient* client = [[Growthbeat sharedInstance] waitClient];
        NSLog(@"clientId is %@", client.id);
    });

    [[GrowthPush sharedInstance] requestDeviceToken];
    [[GrowthPush sharedInstance] trackEvent:@"AllowPushPermission"];
    
    return YES;
}

- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        [[GrowthLink sharedInstance] handleUniversalLinks:webpageURL];
    }
    return true;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    [[GrowthPush sharedInstance] trackEvent:@"Launch"];
}

- (void) applicationWillResignActive:(UIApplication *)application {
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[GrowthLink sharedInstance] handleOpenUrl:url];
    return YES;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[GrowthPush sharedInstance] setDeviceToken:deviceToken];
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotification : %@", error);
}

@end
