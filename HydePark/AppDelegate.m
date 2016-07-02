//
//  AppDelegate.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constants.h"
#import "HomeVC.h"
#import "NavigationHandler.h"
#import "CommentsVC.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *_deviceToken = NULL;
@interface AppDelegate ()
{
       Alert *alert;
}
@end

@implementation AppDelegate
@synthesize viewController,navigationController,loggedInSession = _loggedInSession,strEmail,strFirstN,strLastN,strUserId,user_id,isLoggedIn,videotoPlay,videotitle,videotags,videoUploader,IS_celeb,IS_userChannel,currentScreen,commentObj,hasBeenUpdated,hasBlockedSomeOne,hasbeenEdited,emailGPLus,videObj,latestVideoAdded,navigationControllersCount,currentMyCornerIndex,videomodel,progressFloat,friendsArray;

NSString *const FBSessionStateChangedNotification = @"FBSessionStateChangedNotification";










- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  ///////////
   
    ////////////////////////
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NavigationHandler *navHandler = [[NavigationHandler alloc] initWithMainWindow:self.window];
    [navHandler loadFirstVC];
    
    [self.window makeKeyAndVisible];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    }
    NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (userInfo && application.applicationState != UIApplicationStateActive) {
        NSString *type = [userInfo objectForKey:@"notification_type"];
        if ([type isEqualToString:@"LIKE_POST"]) {
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToLikeBeam:videomodel];

        }else if ([type isEqualToString:@"LIKE_COMMENT"]) {
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }
        else if ([type isEqualToString:@"TAG_FRIENDS"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }else if([type isEqualToString:@"COMMENT_COMMENT"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }
        else if ([type isEqualToString:@"COMMENT_POST"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }else if ([type  isEqualToString:@"REQUEST_RECIEVED"]){
            NSString *friendID = [userInfo objectForKey:@"friend_id"];
            [[NavigationHandler getInstance] MoveToUserChannel:friendID];
        }else if([type isEqualToString:@"REQUEST_ACCEPTED"]){
           
        }
        else if ([type isEqualToString:@"FOLLOWED"])
        {
            NSString *friendID = [userInfo objectForKey:@"friend_id"];
            [[NavigationHandler getInstance] MoveToUserChannel:friendID];
        }
    }
    [FBLoginView class];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    //return YES;
}
+(NSString *)getDeviceToken{
    
    return _deviceToken;
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceToken1 = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken1 = [deviceToken1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    _deviceToken = deviceToken1;
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push received: %@", userInfo);
    NSString *message = [userInfo objectForKey:@"message"];
    NSString *type = [userInfo objectForKey:@"notification_type"];
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        if ([type isEqualToString:@"LIKE_POST"]) {
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToLikeBeam:videomodel];
            
        }else if ([type isEqualToString:@"LIKE_COMMENT"]) {
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }
        else if ([type isEqualToString:@"TAG_FRIENDS"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }else if([type isEqualToString:@"COMMENT_COMMENT"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
        }
        else if ([type isEqualToString:@"COMMENT_POST"]){
            NSDictionary *postDate = [userInfo objectForKey:@"post"];
            NSString *pID  = [userInfo objectForKey:@"parent_comment_id"];
            videomodel = [[VideoModel alloc]init];
            videomodel.userName             = [postDate valueForKey:@"full_name"];
            videomodel.is_anonymous         = [postDate valueForKey:@"is_anonymous"];
            videomodel.title                = [postDate valueForKey:@"caption"];
            videomodel.comments_count       = [postDate valueForKey:@"comment_count"];
            videomodel.topic_id             = [postDate valueForKey:@"topic_id"];
            videomodel.user_id              = [postDate valueForKey:@"user_id"];
            videomodel.profile_image        = [postDate valueForKey:@"profile_link"];
            videomodel.like_count           = [postDate valueForKey:@"like_count"];
            videomodel.seen_count           = [postDate valueForKey:@"seen_count"];
            videomodel.video_link           = [postDate valueForKey:@"video_link"];
            videomodel.video_thumbnail_link = [postDate valueForKey:@"video_thumbnail_link"];
            videomodel.videoID              = [postDate valueForKey:@"id"];
            videomodel.Tags                 = [postDate valueForKey:@"tag_friends"];
            videomodel.video_length         = [postDate valueForKey:@"video_length"];
            videomodel.like_by_me           = [postDate valueForKey:@"like_by_me"];
            videomodel.reply_count          = [postDate objectForKey:@"reply_count"];
            [[NavigationHandler getInstance] MoveToCommentsNotifi:videomodel second:pID];
            
        }else if ([type  isEqualToString:@"REQUEST_RECIEVED"]){
            NSString *friendID = [userInfo objectForKey:@"friend_id"];
            [[NavigationHandler getInstance] MoveToUserChannel:friendID];
        }else if([type isEqualToString:@"REQUEST_ACCEPTED"]){
            
        }
        else if ([type isEqualToString:@"FOLLOWED"])
        {
            NSString *friendID = [userInfo objectForKey:@"friend_id"];
            [[NavigationHandler getInstance] MoveToUserChannel:friendID];
        }

    }
    else{
        [self showAlert:message];
    }
}
-(void) showAlert:(NSString *)message{
    alert = [[Alert alloc] initWithTitle:message duration:(float)2.0f completion:^{
        //
    }];
    [alert setDelegate:self];
    [alert setShowStatusBar:YES];
    [alert setAlertType:AlertTypeSuccess];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
}
#pragma mark - Twitter SDK
- (void)getTwitterAccountOnCompletion:(void (^)(ACAccount *))completionHandler {
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Remember that twitterType was instantiated above
            NSArray *twitterAccounts = [store accountsWithAccountType:twitterType];
            
            // If there are no accounts, we need to pop up an alert
            if(twitterAccounts == nil || [twitterAccounts count] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            } else {
                //Get the first account in the array
                ACAccount *twitterAccount = [twitterAccounts objectAtIndex:0];
                //Save the used SocialAccountType so it can be retrieved the next time the app is started.
                
                //Call the completion handler so the calling object can retrieve the twitter account.
                completionHandler(twitterAccount);
            }
        }
    }];
    
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                
                [FBRequestConnection
                 startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                   NSDictionary<FBGraphUser> *user,
                                                   NSError *error) {
                     if (!error) {
                         self.loggedInSession = FBSession.activeSession;
                     }
                 }];
            
            break;
            }
        case FBSessionStateClosed:
        {
                break;
        }
        case FBSessionStateClosedLoginFailed:
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"BackToHydePark"
             object:nil];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        
        
        //When cancel button is pressed on fb login view
        
        //        UIAlertView *alertView = [[UIAlertView alloc]
        //                                  initWithTitle:@"Error"
        //                                  message:error.localizedDescription
        //                                  delegate:nil
        //                                  cancelButtonTitle:@"OK"
        //                                  otherButtonTitles:nil];
        //        [alertView show];
    }
}


- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray * permissions = [[NSArray alloc] initWithObjects:@"publish_actions",@"email",@"user_friends",@"user_location",@"user_birthday",@"public_profile", nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                         }];
    
    
    //        FBLoginView *loginView =
    //        [[FBLoginView alloc] initWithReadPermissions:@[@"Public_profile", @"email", @"user_likes"]];
}
- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([_strSocial isEqualToString:@"Facebook"]){
        
      //  return [FBSession.activeSession handleOpenURL:url];
        
        return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        
    } if ([_strSocial isEqualToString:@"GPlus"]) {
//        return [GPPURLHandler handleURL:url
//                      sourceApplication:sourceApplication
//                             annotation:annotation];
        return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication
                                          annotation:annotation];
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the 
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];

    if (FBSession.activeSession.state == FBSessionStateCreatedOpening) {
        [FBSession.activeSession close];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

@end
