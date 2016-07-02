//
//  JSAccountsService.m
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import "JSAccountsService.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "JSFbConstants.h"

@interface JSAccountsService()
{
    __block ACAccount *facebookAccount;

}
@end

@implementation JSAccountsService


- (NSError *)createErrorMessageForObject:(NSString * )message
{
    NSError *error = [NSError errorWithDomain:@"Failed!"
                                         code:100
                                     userInfo:@{
                                                NSLocalizedDescriptionKey:message
                                                }];
    NSLog(@"Failed with Response: %@", message);
    return error;
}

-(NSError * ) checkErrorDictionary:(NSDictionary *) errorDictionary{

    NSDictionary *errorDict = @{
                                NSLocalizedDescriptionKey : errorDictionary[@"message"],
                                NSUnderlyingErrorKey : @"", NSFilePathErrorKey : @""
                                };
    
    NSNumber *errorCode = [errorDictionary valueForKey:@"code"];
    
    NSError *anError = [[NSError alloc] initWithDomain:errorDictionary[@"type"]
                                                  code:errorCode.intValue
                                              userInfo:errorDict];
    
    if ([errorCode isEqualToNumber:[NSNumber numberWithInt:190]]) {
        
        NSLog(@"Renew");
        return anError;
    }
    if ([errorCode isEqualToNumber:[NSNumber numberWithInt:2500]]) {
        
        return anError;
    }
    
    return nil;
}


-(void) getFacebookPremission:(NSArray *) premissions
                      success:(void(^)(bool granted)) success
                      failure:(void(^)(NSError *error))failure{
    
    NSLog(@"requested premission : %@",premissions);
    
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *accountType   = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    [accountStore requestAccessToAccountsWithType:accountType
                                          options:@{
                                                     ACFacebookAppIdKey : FB_APP_ID,
                                                     ACFacebookPermissionsKey : premissions,
                                                     ACFacebookAudienceKey : ACFacebookAudienceFriends
                                                   }
                                       completion:^(BOOL granted, NSError *error)
     {
         
         NSLog(@"%@",error.localizedDescription);
         
         if (granted)
         {
             
             NSArray * facebookAccounts=[accountStore accountsWithAccountType:accountType];
             
             facebookAccount = [facebookAccounts lastObject];
             
             [accountStore renewCredentialsForAccount:facebookAccount
                                           completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                                               
                                           }];
             
             NSLog(@"%@",facebookAccount.username);
             NSLog(@"%@",facebookAccount.accountDescription);
             NSLog(@"%@",facebookAccounts);
             
             success(true);
             
         }
         
         else
         {
             
             // Fail gracefully...
             
             NSLog(@"%@",error.description);
             
             if (error == nil) {
                 
                 NSLog(@"%@",App_Disabled);
                 
                 error = [self createErrorMessageForObject:App_Disabled];
                 
             }
             else if([error code]== ACErrorAccountNotFound){
                 
                 error = [self createErrorMessageForObject:FB_Acc_Not_found];
             }
             
             failure(error);
         }
         
     }];
}


-(void) getUserInfoWithcompleted:(loadAccSuccess)completed
                          failed:(loadAccFailure)failed {
    
    
    [self getFacebookPremission:[FB_PERMISSION_EMAIL componentsSeparatedByString:@","]
                        success:^(bool granted) {
                            
        NSURL *requestURL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                requestMethod:SLRequestMethodGET
                                                          URL:requestURL
                                                   parameters:nil];
        request.account = facebookAccount;
        
        [request performRequestWithHandler:^(NSData *data,
                                             NSHTTPURLResponse *response,
                                             NSError *error)
         {
             if(!error)
             {
                 NSDictionary *dataObj =[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                 
                 NSDictionary *errorDict = [dataObj valueForKey:@"error"];
                 
                 if (errorDict) {
                     
                     failed([self checkErrorDictionary:errorDict]);
                 }
                 
                 NSLog(@"%@",dataObj);
                 
                 JSUser *user = [JSUser new];
                 
                 user.facebookID    = [JSUser validStringForObject:dataObj[@"id"]];
                 user.birthday      = [JSUser validStringForObject:dataObj[@"birthday"]];
                 user.gender        = [JSUser validStringForObject:dataObj[@"gender"]];
                 user.name          = [JSUser validStringForObject:dataObj[@"name"]];
                 user.firstName     = [JSUser validStringForObject:dataObj[@"first_name"]];
                 user.lastName      = [JSUser validStringForObject:dataObj[@"last_name"]];
                 user.email         = [JSUser validStringForObject:dataObj[@"email"]];
                 user.country       = [JSUser validStringForObject:dataObj[@"location"][@"name"]];
                 user.imageURL      = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=100&type=normal&width=100",user.facebookID];
                 
                 completed(user);
             }
             else
             {
                 failed(error);
             }
             
         }];
        
    } failure:^(NSError *error) {
        
        failed(error);
    }];

}


-(void) postMessageOnWall:(NSString *) message
                completed:(loadAccSuccess)completed
                   failed:(loadAccFailure)failed {
    
    [self getFacebookPremission:[FB_PERMISSION_PUB_ACTOIN componentsSeparatedByString:@","]
                        success:^(bool granted) {
                            
        NSDictionary *parameters = @{@"message": message};
        
        NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
        
        
        SLRequest *feedRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:feedURL
                                                       parameters:parameters];
        
        feedRequest.account = facebookAccount;
        
        [feedRequest performRequestWithHandler:^(NSData *responseData,
                                                 NSHTTPURLResponse *urlResponse, NSError *error)
         {
             
             id data = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
             
             NSLog(@"error : %@,   data: %@", error, data);
             
             if (data) {
                 
             }
             else{
                 failed(error);
             }
             
         }];
        
    } failure:^(NSError *error) {
        
        failed(error);
    }];
}

@end
