//
//  CustomLoading.h
//  Wits
//
//  Created by Obaid ur Rehman on 01/09/2015.
//  Copyright (c) 2015 Xint Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomLoading : UIView

+ (void)showAlertMessage ;
+(void)DismissAlertMessage;
@property (strong, retain) IBOutlet UIImageView *coinImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndc;

@end
