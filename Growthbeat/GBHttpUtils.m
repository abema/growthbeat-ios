//
//  GBHttpUtils.m
//  GrowthbeatCore
//
//  Created by Naoyuki Kataoka on 2014/06/12.
//  Copyright (c) 2014 SIROK, Inc. All rights reserved.
//

#import "GBHttpUtils.h"

@implementation GBHttpUtils

+ (NSString *) queryStringWithDictionary:(NSDictionary *)params {

    NSMutableArray *combinedParams = [NSMutableArray array];

    for (NSString *key in [params keyEnumerator]) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id values = [params objectForKey:key];
        if (![values isKindOfClass:[NSArray class]]) {
            values = [NSArray arrayWithObject:values];
        }
        for (id value in values) {
            NSString *encodedValue = [[NSString stringWithFormat:@"%@", value] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [combinedParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }

    return [combinedParams componentsJoinedByString:@"&"];

}

+ (NSDictionary *) dictionaryWithQueryString:(NSString *)queryString {

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    for (NSString *nameValuePair in [queryString componentsSeparatedByString:@"&"]) {
        NSString *predecodedNameValuePair = [nameValuePair stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        NSRange range = [predecodedNameValuePair rangeOfString:@"="];
        if (range.location == NSNotFound) {
            continue;
        }
        NSString *key = [[predecodedNameValuePair substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[predecodedNameValuePair substringFromIndex:range.location + 1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (!key || !value) {
            continue;
        }
        [dictionary setObject:value forKeyedSubscript:key];
    }

    return dictionary;

}

+ (NSData *) formUrlencodedBodyWithDictionary:(NSDictionary *)params {
    return [[self queryStringWithDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *) jsonBodyWithDictionary:(NSDictionary *)params {
    return [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
}

@end
