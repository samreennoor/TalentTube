//
//  JSFBKitService.m
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import "JSFBSdkService.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation JSFBSdkService

-(void) getUserInfoWithcompleted:(loadKitSuccess)completed
                          failed:(loadKitFailure)failed {
    
    FBSDKLoginManager *login = [FBSDKLoginManager new];
    [login logOut];
    
    [login logInWithReadPermissions: [FB_PERMISSION_EMAIL componentsSeparatedByString:@","]
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                
                                    NSLog(@"Process error");
                                
                                    failed(error);
                                    
                                } else if (result.isCancelled) {
                                    
                                    failed(nil);
                                    
                                    NSLog(@"Cancelled");
                                    
                                } else {
                                    
                                    NSLog(@"Logged in");
                                    
                                    if ([FBSDKAccessToken currentAccessToken]) {
                                        
                                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                           parameters:@{@"fields": @"email, first_name, last_name, gender"}]
                                         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                                        {
                                             
                                             if (!error) {
                                                 
                                                 NSDictionary *  dataObj = result;
                                             
                                                 NSLog(@"fetched user: %@", result);
                                                 
                                                 JSUser *user = [JSUser new];
                                                 
                                                 user.facebookID    = [JSUser validStringForObject:dataObj[@"id"]];
                                                 user.gender        = [JSUser validStringForObject:dataObj[@"gender"]];
                                                 user.firstName     = [JSUser validStringForObject:dataObj[@"first_name"]];
                                                 user.lastName      = [JSUser validStringForObject:dataObj[@"last_name"]];
                                                 user.email         = [JSUser validStringForObject:dataObj[@"email"]];
                                                 user.imageURL      = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=100&type=normal&width=100",user.facebookID];

                                                 completed(user);
                                                 
                                             }
                                             else{
                                             
                                                 failed(error);
                                             }
                                         
                                        }];
                                    }
                                    
                                }
                            }];
    
}


-(void) postMessageOnWall:(NSString *) message
                completed:(loadKitSuccess) completed
                   failed:(loadKitFailure) failed{
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {

        if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/feed"
                                               parameters: @{ @"message" : message}
                                               HTTPMethod:@"POST"]
             
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 
                 if (!error) {
                     
                     NSLog(@"Post id:%@", result[@"id"]);
                     
                 }
             }];
        }
    
    } else {
        
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithPublishPermissions:@[@"publish_actions"]
                                          handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
        {
            if (error) {

                failed(error);
            
            }
            else if (result.isCancelled) {
                
                failed(nil);
                
                NSLog(@"Cancelled");
                
            }
            else{
            
                [self postMessageOnWall:message completed:completed failed:failed];
                
            }
        }];
    }
}


-(void) userLikesr{
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_likes"]) {
        FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:@"me" parameters:nil];
        FBSDKGraphRequest *requestLikes = [[FBSDKGraphRequest alloc]
                                           initWithGraphPath:@"me/likes" parameters:nil];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        [connection addRequest:requestMe
             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //TODO: process me information
             }];
        [connection addRequest:requestLikes
             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //TODO: process like information
             }];
        [connection start];
    }
}


@end
