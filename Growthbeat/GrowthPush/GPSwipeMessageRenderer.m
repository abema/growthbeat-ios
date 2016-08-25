//
//  MPSwipeMessgeRenderer.m
//  GrowthbeatSample
//
//  Created by TABATAKATSUTOSHI on 2016/06/15.
//  Copyright © 2016年 SIROK, Inc. All rights reserved.
//

#import "GPSwipeMessageRenderer.h"
#import "GPPicture.h"
#import "GPCloseButton.h"
#import "GPImageButton.h"
#import "GBViewUtils.h"
#import "GrowthPush.h"
#import "GPPictureUtils.h"

static NSTimeInterval const kGPSwipeMessageRendererImageDownloadTimeout = 10;
static NSInteger const kGPCloseButtonPadding = 8;
static CGFloat const kPagingMargin = 16.f;
static CGFloat const kPagingHeight = 8.f;
static NSInteger const kGPBackgroundTagId = 9999;

@interface GPSwipeMessageRenderer () {
    
    NSMutableDictionary *boundButtons;
    NSMutableDictionary *cachedImages;
    UIView *backgroundView;
    NSInteger currentPage;
    BOOL alreadyRender;
}

@property (nonatomic, strong) NSMutableDictionary *boundButtons;
@property (nonatomic, strong) NSMutableDictionary *cachedImages;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL alreadyRender;

@end

@implementation GPSwipeMessageRenderer

@synthesize swipeMessage;
@synthesize delegate;
@synthesize boundButtons;
@synthesize cachedImages;
@synthesize backgroundView;
@synthesize scrollView;
@synthesize pageControl;
@synthesize currentPage;
@synthesize alreadyRender;

- (instancetype) initWithSwipeMessage:(GPSwipeMessage *)newSwipeMessage {
    self = [super init];
    if (self) {
        self.swipeMessage = newSwipeMessage;
        self.boundButtons = [NSMutableDictionary dictionary];
        self.cachedImages = [NSMutableDictionary dictionary];
        self.currentPage = 0;
        self.alreadyRender = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    return self;
}

- (void) show {
    
    UIWindow *window = [GBViewUtils getWindow];
    
    if (!self.backgroundView) {
        self.backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = [GBViewUtils hexToUIColor:[NSString stringWithFormat:@"%lX",(long) self.swipeMessage.background.color] alpha:self.swipeMessage.background.opacity];
        backgroundView.tag = kGPBackgroundTagId;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(backgroundTouched:)];
        [singleFingerTap setDelegate:self];
        singleFingerTap.numberOfTapsRequired = 1;
        singleFingerTap.numberOfTouchesRequired = 1;
        backgroundView.userInteractionEnabled = true;
        [backgroundView addGestureRecognizer:singleFingerTap];
    }
    
    for (UIView *subview in backgroundView.subviews) {
        [subview removeFromSuperview];
    }
    
    UIView *baseView = [[UIView alloc] initWithFrame:backgroundView.frame];
    [backgroundView addSubview:baseView];
    baseView.tag = 1;
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGFloat screenWidth = window.frame.size.width;
    CGFloat screenHeight = window.frame.size.height;
    CGFloat height = self.swipeMessage.baseHeight;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f &&
        ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft ||
         [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight ||
         [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown)) {
            
            switch ([UIApplication sharedApplication].statusBarOrientation) {
                case UIDeviceOrientationLandscapeLeft:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
                    break;
                case UIDeviceOrientationLandscapeRight:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * -0.5);
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    baseView.transform = CGAffineTransformMakeRotation(M_PI * 1);
                    break;
                default:
                    break;
            }

            screenHeight = window.frame.size.width;
            screenWidth = window.frame.size.height;
            baseView.bounds = CGRectMake(0, 0, screenWidth, screenHeight);
            
        }
    
    
    height += (kPagingHeight + kPagingMargin);
    if (swipeMessage.swipeType == GPSwipeMessageTypeOneButton) {
        NSArray *imageButtons = [self extractButtonsWithType:GPButtonTypeImage];
        GPImageButton *imageButton = [imageButtons objectAtIndex:0];
        CGSize imageSize = [GPPictureUtils calculatePictureSize:imageButton.picture baseWidth:imageButton.baseWidth baseHeight:imageButton.baseHeight];
        height += imageSize.height;
    }
    
    CGFloat x = (screenWidth - self.swipeMessage.baseWidth) / 2;
    CGFloat y = (screenHeight - height) / 2;
    [self showScrollView:baseView rect:CGRectMake(x, y, self.swipeMessage.baseWidth, self.swipeMessage.baseHeight)];
    [self showPageControlWithView:baseView rect:CGRectMake(x, y + height - kPagingHeight, self.swipeMessage.baseWidth, kPagingHeight)];
    
    [self cacheImages:^{
        
        void(^renderCallback)() = ^() {
            dispatch_async(dispatch_get_main_queue(), ^{
                alreadyRender = YES;
                [window addSubview:backgroundView];
                [self showImageWithView:scrollView rect:CGRectMake(x, y, self.swipeMessage.baseWidth, self.swipeMessage.baseHeight)];
                [scrollView setContentOffset:CGPointMake(self.currentPage * self.swipeMessage.baseWidth, 0) animated:NO];
                
                switch (swipeMessage.swipeType) {
                    case GPSwipeMessageTypeOneButton: {
                        [self showImageButtonWithView:baseView rect:CGRectMake((screenWidth - self.swipeMessage.baseWidth) / 2, (screenHeight - self.swipeMessage.baseHeight - (height - self.swipeMessage.baseHeight)) / 2, self.swipeMessage.baseWidth, self.swipeMessage.baseHeight)];
                        break;
                    }
                    case GPSwipeMessageTypeImageOnly:
                        break;
                    default:
                        break;
                }
                
            });
        };
        
        GPShowMessageHandler *showMessageHandler = [[[GrowthPush sharedInstance] showMessageHandlers] objectForKey:swipeMessage.id];
        if(!alreadyRender && showMessageHandler) {
            showMessageHandler.handleMessage(^{
                renderCallback();
            });
        } else {
            renderCallback();
        }
        
    }];
    
}

- (void) showScrollView:view rect:(CGRect)rect {
    scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    [scrollView setContentSize:CGSizeMake(([swipeMessage.pictures count] * rect.size.width), rect.size.height)];
    [view addSubview:scrollView];
}

- (void) scrollViewDidScroll:(UIScrollView *)_scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    
    if ((NSInteger)fmod(scrollView.contentOffset.x, pageWidth) == 0) {
        pageControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
    
    self.currentPage = self.pageControl.currentPage;
}

- (void) showImageWithView:(UIView *)view rect:(CGRect)rect {
    
    for (int i = 0; i < [swipeMessage.pictures count]; i++) {
        
        GPPicture *picture = [swipeMessage.pictures objectAtIndex:i];
        CGSize size = [GPPictureUtils calculatePictureSize:picture baseWidth:self.swipeMessage.baseWidth baseHeight:self.swipeMessage.baseHeight];
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat left = ((rect.size.width - width) / 2) + (rect.size.width * i);
        CGFloat top = (rect.size.height - height) / 2;
        CGRect imageRect = CGRectMake(left, top, width, height);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageRect];
        
        imageView.image = [cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:picture.url]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [view addSubview:imageView];
        
        CGRect closeButtonRect = CGRectMake(0, 0, width, height);
        [self showCloseButtonWithView:imageView rect:closeButtonRect];
        
    }
    
}

- (void) showImageButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    NSArray *imageButtons = [self extractButtonsWithType:GPButtonTypeImage];
    
    switch (swipeMessage.swipeType) {
        case GPSwipeMessageTypeImageOnly:
            return;
        case GPSwipeMessageTypeOneButton:
        {
            GPImageButton *imageButton = [imageButtons objectAtIndex:0];
            
            CGSize imageSize = [GPPictureUtils calculatePictureSize:imageButton.picture baseWidth:imageButton.baseWidth baseHeight:imageButton.baseHeight];
            CGFloat width = imageSize.width;
            CGFloat height = imageSize.height;
            CGFloat left = rect.origin.x + (rect.size.width - width) / 2;
            CGFloat top = rect.origin.y + rect.size.height;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:imageButton.picture.url]] forState:UIControlStateNormal];
            button.contentMode = UIViewContentModeScaleAspectFit;
            button.frame = CGRectMake(left, top, width, height);
            [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            [boundButtons setObject:imageButton forKey:[NSValue valueWithNonretainedObject:button]];
            break;
        }
        default:
            break;
    }
    
}

- (void) showCloseButtonWithView:(UIView *)view rect:(CGRect)rect {
    
    GPCloseButton *closeButton = [[self extractButtonsWithType:GPButtonTypeClose] lastObject];
    
    if (!closeButton) {
        return;
    }
    
    CGSize imageSize = [GPPictureUtils calculatePictureSize:closeButton.picture baseWidth:closeButton.baseWidth baseHeight:closeButton.baseHeight];
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat left = rect.origin.x + rect.size.width - width - kGPCloseButtonPadding;
    CGFloat top = rect.origin.y + kGPCloseButtonPadding;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[cachedImages objectForKey:[GBViewUtils addDensityByPictureUrl:closeButton.picture.url]] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    button.frame = CGRectMake(left, top, width, height);
    [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    [boundButtons setObject:closeButton forKey:[NSValue valueWithNonretainedObject:button]];
    
}

- (NSArray *) extractButtonsWithType:(GPButtonType)type {
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for (GPButton *button in swipeMessage.buttons) {
        if (button.type == type) {
            [buttons addObject:button];
        }
    }
    
    return buttons;
    
}

- (void) showPageControlWithView:(UIView *)view rect:(CGRect)rect {
    
    pageControl = [[UIPageControl alloc] initWithFrame:rect];
    
    pageControl.numberOfPages = [swipeMessage.pictures count];
    pageControl.currentPage = self.currentPage;
    pageControl.userInteractionEnabled = NO;
    [view addSubview:pageControl];
    
}

- (void) cacheImages:(void (^)(void))callback {
    
    NSMutableArray *urlStrings = [NSMutableArray array];
    
    for (int i = 0; i < [swipeMessage.pictures count]; i++) {
        GPPicture *picture = [swipeMessage.pictures objectAtIndex:i];
        if (picture.url) {
            [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:picture.url]];
        }
    }
    
    for (GPButton *button in swipeMessage.buttons) {
        switch (button.type) {
            case GPButtonTypeImage:
                if (((GPImageButton *)button).picture.url) {
                    [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:((GPImageButton *)button).picture.url]];
                }
                break;
            case GPButtonTypeClose:
                if (((GPCloseButton *)button).picture.url) {
                    [urlStrings addObject:[GBViewUtils addDensityByPictureUrl:((GPCloseButton *)button).picture.url]];
                }
                break;
            default:
                continue;
        }
    }
    
    for (NSString *urlString in [urlStrings objectEnumerator]) {
        [self cacheImageWithUrlString:urlString completion:^(NSString *urlString){
            
            [urlStrings removeObject:urlString];
            if (![cachedImages objectForKey:urlString]) {
                [self.backgroundView removeFromSuperview];
                self.backgroundView = nil;
            }
            
            if ([urlStrings count] == 0 && callback) {
                callback();
            }
            
        }];
    }
    
}

- (void) cacheImageWithUrlString:(NSString *)urlString completion:(void (^)(NSString *urlString))completion {
    
    if ([cachedImages objectForKey:urlString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(urlString);
            }
        });
        return;
    }
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kGPSwipeMessageRendererImageDownloadTimeout];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!data || error) {
            if (completion) {
                completion(urlString);
            }
            return;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            [cachedImages setObject:image forKey:urlString];
        }
        if (completion) {
            completion(urlString);
        }
        
    }];
    
}

- (void) tapButton:(id)sender {
    
    GPButton *button = [boundButtons objectForKey:[NSValue valueWithNonretainedObject:sender]];
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    
    [delegate clickedButton:button message:swipeMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)backgroundTouched:(UITapGestureRecognizer *)recognizer {
    if (!swipeMessage.background.outsideClose || recognizer.view.tag != kGPBackgroundTagId)
        return;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    self.boundButtons = nil;
    [delegate backgroundTouched:swipeMessage];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag != 1)
    {
        return false;
    }
    return true;
}


@end
