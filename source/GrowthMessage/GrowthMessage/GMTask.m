//
//  GMTask.m
//  GrowthMessage
//
//  Created by Naoyuki Kataoka on 2015/03/15.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GMTask.h"
#import "GBDateUtils.h"

static NSString *const kGMTaskId = @"id";
static NSString *const kGMTaskApplicationId = @"applicationId";
static NSString *const kGMTaskName = @"name";
static NSString *const kGMTaskDescription = @"description";
static NSString *const kGMTaskAvailableFrom = @"availableFrom";
static NSString *const kGMTasAvailableTo= @"availableTo";
static NSString *const kGMTasDisabled= @"disabled";
static NSString *const kGMCreated= @"created";
static NSString *const kGMTasUpdated= @"updated";

@implementation GMTask

@synthesize id;
@synthesize applicationId;
@synthesize name;
@synthesize description;
@synthesize availableFrom;
@synthesize availableTo;
@synthesize disabled;
@synthesize created;
@synthesize updated;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (self) {
        if ([dictionary objectForKey:kGMTaskId] && [dictionary objectForKey:kGMTaskId] != [NSNull null]) {
            self.id = [dictionary objectForKey:kGMTaskId];
        }
        if ([dictionary objectForKey:kGMTaskApplicationId] && [dictionary objectForKey:kGMTaskApplicationId] != [NSNull null]) {
            self.applicationId = [dictionary objectForKey:kGMTaskApplicationId];
        }
        if ([dictionary objectForKey:kGMTaskName] && [dictionary objectForKey:kGMTaskName] != [NSNull null]) {
            self.name = [dictionary objectForKey:kGMTaskName];
        }
        if ([dictionary objectForKey:kGMTaskDescription] && [dictionary objectForKey:kGMTaskDescription] != [NSNull null]) {
            self.description = [dictionary objectForKey:kGMTaskDescription];
        }
        if ([dictionary objectForKey:kGMTaskAvailableFrom] && [dictionary objectForKey:kGMTaskAvailableFrom] != [NSNull null]) {
            self.availableFrom = [dictionary objectForKey:kGMTaskAvailableFrom];
        }
        if ([dictionary objectForKey:kGMTasAvailableTo] && [dictionary objectForKey:kGMTasAvailableTo] != [NSNull null]) {
            self.availableTo = [dictionary objectForKey:kGMTasAvailableTo];
        }
        if ([dictionary objectForKey:kGMTasDisabled] && [dictionary objectForKey:kGMTasDisabled] != [NSNull null]) {
            self.disabled = [[dictionary objectForKey:kGMTasDisabled] boolValue];
        }
        if ([dictionary objectForKey:kGMCreated] && [dictionary objectForKey:kGMCreated] != [NSNull null]) {
            self.created = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:kGMCreated]];
        }
        if ([dictionary objectForKey:kGMTasUpdated] && [dictionary objectForKey:kGMTasUpdated] != [NSNull null]) {
            self.updated = [GBDateUtils dateWithDateTimeString:[dictionary objectForKey:kGMTasUpdated]];
        }
    }
    return self;

}

#pragma mark --
#pragma mark NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:kGMTaskId]) {
            self.id = [aDecoder decodeObjectForKey:kGMTaskId];
        }
        if ([aDecoder containsValueForKey:kGMTaskApplicationId]) {
            self.applicationId = [aDecoder decodeObjectForKey:kGMTaskApplicationId];
        }
        if ([aDecoder containsValueForKey:kGMTaskName]) {
            self.name = [aDecoder decodeObjectForKey:kGMTaskName];
        }
        if ([aDecoder containsValueForKey:kGMTaskDescription]) {
            self.description = [aDecoder decodeObjectForKey:kGMTaskDescription];
        }
        if ([aDecoder containsValueForKey:kGMTaskAvailableFrom]) {
            self.availableFrom = [aDecoder decodeObjectForKey:kGMTaskAvailableFrom];
        }
        if ([aDecoder containsValueForKey:kGMTasAvailableTo]) {
            self.availableTo = [aDecoder decodeObjectForKey:kGMTasAvailableTo];
        }
        if ([aDecoder containsValueForKey:kGMTasDisabled]) {
            self.disabled = [aDecoder decodeBoolForKey:kGMTasDisabled];
        }
        if ([aDecoder containsValueForKey:kGMCreated]) {
            self.created = [aDecoder decodeObjectForKey:kGMCreated];
        }
        if ([aDecoder containsValueForKey:kGMTasUpdated]) {
            self.updated = [aDecoder decodeObjectForKey:kGMTasUpdated];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:id forKey:kGMTaskId];
    [aCoder encodeObject:applicationId forKey:kGMTaskApplicationId];
    [aCoder encodeObject:name forKey:kGMTaskName];
    [aCoder encodeObject:description forKey:kGMTaskDescription];
    [aCoder encodeObject:availableFrom forKey:kGMTaskAvailableFrom];
    [aCoder encodeObject:availableTo forKey:kGMTasAvailableTo];
    [aCoder encodeBool:disabled forKey:kGMTasDisabled];
    [aCoder encodeObject:created forKey:kGMCreated];
    [aCoder encodeObject:updated forKey:kGMTasUpdated];
}

@end
