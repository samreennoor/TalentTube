//
//  JSFacebookManager.m
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import "JSFacebookManager.h"

#import "JSAccountsService.h"
#import "JSFBSdkService.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>


@interface JSFacebookManager()
{
    JSAccountsService   * accountsService;
    JSFBSdkService      * fbKitService;
}
@end

@implementation JSFacebookManager


#pragma mark - Class methods

+ (JSFacebookManager *)sharedManager
{
    static JSFacebookManager* sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[JSFacebookManager alloc] init];
    });
    
    return sharedInstance;
}

-(BOOL) isLocalAccountExist{
   
    // Work on Device.
    BOOL userSetupFbAccountLocally = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    
    ACAccountStore *myStore = [[ACAccountStore alloc] init];
    ACAccountType *acct = [myStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *fbAccounts = [myStore accountsWithAccountType:acct];
    
    // Check to make sure the user has a FB account setup, or bail:
    if ([fbAccounts count] == 0) {

        return NO;
    } else {
    
        return YES;
    }

    return userSetupFbAccountLocally;
}

-(void) getUserInfoWithCompletion:(loadSuccess) completed
                          failure:(loadFailure) failed{
    
    if ([self isLocalAccountExist]) {
        
        if (!accountsService)
            accountsService = [JSAccountsService new];
        
        [accountsService getUserInfoWithcompleted:^(id data) {
            
            completed(data);
            
        } failed:^(NSError *error) {
            
            failed(error);
        }];
    
    }
    else{
        
        // Facebook SDK
        if (!fbKitService)
            fbKitService = [JSFBSdkService new];

        [fbKitService getUserInfoWithcompleted:^(id data) {
            
            completed(data);
            
        } failed:^(NSError *error) {
            failed(error);
            
        }];
        
    }
}


-(void) postMessageOnMyWall:(NSString *) message
                 completion:(loadSuccess) completed
                    failure:(loadFailure) failed{
    
    if ([self isLocalAccountExist]) {
        
        if (!accountsService)
            accountsService = [JSAccountsService new];
        
        [accountsService postMessageOnWall:message
                                 completed:^(id data)
         {
             
             completed(data);
             
         } failed:^(NSError *error) {
             
             failed(error);
         }];
        
        NSLog(@"YES");
        
    }
    else{
        
        // Facebook SDK
                
        
        NSLog(@"NO");
        
    }
}

-(void) getListOfUserLikesWithCompletion:(loadSuccess) completed
                                 failure:(loadFailure) failed{

}

-(void) getFriendsListWithCompletion:(loadSuccess) completed
                             failure:(loadFailure) failed{

}



@end
