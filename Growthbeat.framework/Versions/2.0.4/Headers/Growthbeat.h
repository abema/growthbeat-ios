//
//  Growthbeat.h
//  Growthbeat
//
//  Created by Kataoka Naoyuki on 2014/06/13.
//  Copyright (c) 2014年 SIROK, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBLogger.h"
#import "GBHttpClient.h"
#import "GBPreference.h"
#import "GBUtils.h"
#import "GBClient.h"
#import "GBAppDelegateWrapper.h"
#import "GrowthPush.h"
#import "GrowthLink.h"
#import "GBIntent.h"
#import "GBIntentHandler.h"
#import "GBUrlIntentHandler.h"
#import "GBNoopIntentHandler.h"
#import "GBCustomIntentHandler.h"
#import "GBCustomIntent.h"

@interface Growthbeat : NSObject {

    NSMutableArray *intentHandlers;

}

@property (nonatomic, strong) NSArray *intentHandlers;

+ (Growthbeat *)sharedInstance;

- (void)initializeWithApplicationId:(NSString *)applicationId credentialId:(NSString *)credentialId;

- (GBLogger *)logger;
- (GBHttpClient *)httpClient;
- (GBPreference *)preference;

- (GBClient *)client;
- (GBClient *)waitClient;

- (void)setLoggerSilent:(BOOL) silent;
- (BOOL)handleIntent:(GBIntent *)intent;
- (void)addIntentHandler:(NSObject *)intentHandler;
- (void)addCustomIntentHandlerWithBlock:(BOOL(^)(GBCustomIntent *customIntent))block;


@end
