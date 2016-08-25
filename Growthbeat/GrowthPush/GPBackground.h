//
//  GPBackground.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/16.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBDomain.h"

@interface GPBackground : GBDomain <NSCoding> {
    
    NSInteger color;
    CGFloat opacity;
    BOOL outsideClose;
    
}

@property (nonatomic, assign) NSInteger color;
@property (nonatomic, assign) CGFloat opacity;
@property (nonatomic, assign) BOOL outsideClose;

@end
