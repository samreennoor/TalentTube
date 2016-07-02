//
//  AppDelegate.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "CommentsModel.h"
#import "VideoModel.h"
#import "Alert.h"
#import "myChannelModel.h"
@class ViewController;
@class HomeVC;

#define kSocialAccountTypeKey @"SOCIAL_ACCOUNT_TYPE"

extern NSString * const FBSessionStateChangedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate,AlertDelegate>

@property (strong, nonatomic) UIWindow *window;

@property ( strong , nonatomic ) UINavigationController *navigationController;
@property ( strong , nonatomic ) ViewController *viewController;
+(NSString *)getDeviceToken;
@property ( strong , nonatomic ) HomeVC *HomeVC;
@property BOOL latestVideoAdded;
@property BOOL loaduserProfiel;
@property NSString *userToView;
@property BOOL isLoggedIn;
@property int navigationControllersCount;

@property int user_id;
@property (strong, nonatomic) NSString *profile_pic_url;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strSocial;
@property (strong, nonatomic) NSString *strFirstN;
@property (strong, nonatomic) NSString *strLastN;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strProfileImage;
@property BOOL IS_celeb;
@property BOOL IS_userChannel;

@property (strong, nonatomic) NSArray  *friendsArray;

@property (nonatomic, retain) NSString *videotoPlay;
@property (nonatomic, retain) NSString *videotitle;
@property (nonatomic, retain) NSString *videotags;
@property (nonatomic, retain) NSString *videoUploader;
@property (nonatomic, retain) NSString *currentScreen;

@property BOOL hasBlockedSomeOne;
@property (strong, nonatomic) FBSession *loggedInSession;
@property (strong, nonatomic) NSString *emailGPLus;
@property (strong, nonatomic) CommentsModel *commentObj;
@property (strong, nonatomic) VideoModel *videObj;
@property (strong, nonatomic) VideoModel *videomodel;
@property BOOL hasBeenUpdated;
@property BOOL hasbeenEdited;
@property BOOL timeToupdateHome;
@property NSUInteger currentMyCornerIndex;
@property float progressFloat;

@property (strong, nonatomic) myChannelModel *myprofile;


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end

