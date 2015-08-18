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
    [[Growthbeat sharedInstance] initializeWithApplicationId:@"PIaD6TaVt7wvKwao" credentialId:@"WFvr3o4cQqUQquqdBzcu0dX4Qcu5ux3i"];
    [[[GrowthMessage sharedInstance] httpClient] setBaseUrl:[NSURL URLWithString:@"http://api.mock.message.growthbeat.com"]];
    [[GrowthLink sharedInstance] initializeWithApplicationId:@"PIaD6TaVt7wvKwao" credentialId:@"WFvr3o4cQqUQquqdBzcu0dX4Qcu5ux3i"];
    [[GrowthPush sharedInstance] requestDeviceTokenWithEnvironment:kGrowthPushEnvironment];
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] start];
}

- (void) applicationWillResignActive:(UIApplication *)application {
    [[Growthbeat sharedInstance] stop];
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
