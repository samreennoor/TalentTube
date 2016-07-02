//
//  JSFbConstants.h
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#ifndef FacebookManager_JSFbConstants_h
#define FacebookManager_JSFbConstants_h

#import "JSUser.h"


#if DEBUG

#define FB_APP_ID          @"616595411828482" // On Alina's Account

#else                   // URL for Dev - Internal Server

#define FB_APP_ID          @"616595411828482" // On Junaid's Account

#endif


#define FB_Acc_Not_found    @"Account not found. Please set up your Facebook account in phone settings."

#define App_Disabled        @"Please enable %@ in the phone settings."

#define FB_PERMISSION_EMAIL         @"public_profile,email"
#define FB_PERMISSION_PUB_ACTOIN    @"publish_actions"
#define FB_PERMISSION_BIRTHDAY      @"user_birthday"
#define FB_PERMISSION_ABOUT_ME      @"user_about_me"

//  @[@"public_profile", @"email", @"user_friends"];


/*
 
 // Add these Methods in AppDelegate with HeaderFile

 #import <FBSDKCoreKit/FBSDKCoreKit.h>

 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
 }
 
 - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
 }
 
 - (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
 }
 
 */

/*
 
 Update the Info Plist with Key and Values
 
 <key>FacebookAppID</key>
	<string>1515673788745391</string>
	<key>FacebookDisplayName</key>
	<string>Alina&apos;s Flowers</string>
	<key>CFBundleURLTypes</key>
	<array>
 <dict>
 <key>CFBundleURLSchemes</key>
 <array>
 <string>fb1515673788745391</string>
 </array>
 </dict>
	</array>
	<key>LSApplicationQueriesSchemes</key>
	<array>
 <string>fbapi</string>
 <string>fb-messenger-api</string>
 <string>fbauth2</string>
 <string>fbshareextension</string>
	</array>
 
 */


#endif
