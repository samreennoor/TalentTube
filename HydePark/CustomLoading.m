//
//  CustomLoading.m
//  Wits
//
//  Created by Obaid ur Rehman on 01/09/2015.
//  Copyright (c) 2015 Xint Solutions. All rights reserved.
//

#import "CustomLoading.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@implementation CustomLoading
static BOOL showing;


CustomLoading *loaderObj;
@synthesize coinImage = _coinImage;

+ (void)showAlertMessage
{
    
    if(showing)
    {
        return;
    }
    showing = true;
    loaderObj = [[[NSBundle mainBundle] loadNibNamed:@"CustomLoading" owner:nil options:nil] objectAtIndex:0];
    [loaderObj showPrivate];
    
}

-(void)showPrivate
{
    
    UIWindow *window =  [[UIApplication sharedApplication].delegate window];
    self.frame = window.frame;
    [window addSubview:self];
    self.center = window.center;
    
    [_activityIndc startAnimating];
    [self frameAnimations];
}

-(void) performAnimation
{
    CALayer *layer = _coinImage.layer;
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -1000;
    rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI / 0.2, 0.0f, 1.0f, 0.0f);
    layer.transform = rotationAndPerspectiveTransform;
    [UIView animateWithDuration:0.1 animations:^{
        layer.transform = CATransform3DIdentity;
        
    }];
}
- (void) startTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) tick:(NSTimer *) timer {
    [self performAnimation];
    
}
+(void) DismissAlertMessage
{
    
    CustomLoading *cusLoading = [[CustomLoading alloc]init];
    if(showing)
    {
        
        [loaderObj dissmiss ];
    }
}
- (void)dissmiss
{
    showing = false;
    _coinImage = nil;
    
    [self removeFromSuperview];
    
}

-(void)frames
{
    
}



-(void)frameAnimations
{
    
    /*_coinImage.animationImages = @[
     [UIImage imageNamed:@"loadingtoken03.png"],
     [UIImage imageNamed:@"loadingtoken04.png"],
     [UIImage imageNamed:@"loadingtoken05.png"],
     [UIImage imageNamed:@"loadingtoken06.png"],
     [UIImage imageNamed:@"loadingtoken07.png"]];
     _coinImage.animationDuration = 1.25;
     
     [_coinImage startAnimating];*/
}
@end
