//
//  GPImageMessage.h
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPMessage.h"
#import "GPPicture.h"

@interface GPCardMessage : GPMessage {
    
    GPPicture *picture;
    NSInteger baseWidth;
    NSInteger baseHeight;
    
}

@property (nonatomic, strong) GPPicture *picture;
@property (nonatomic, assign) NSInteger baseWidth;
@property (nonatomic, assign) NSInteger baseHeight;

@end
