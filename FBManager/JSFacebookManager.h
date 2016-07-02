//
//  JSFacebookManager.h
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSUser.h"

@interface JSFacebookManager : NSObject

typedef void (^loadSuccess)(id data);
typedef void (^loadFailure)(NSError *error);

+ (JSFacebookManager *)sharedManager;

-(void) getUserInfoWithCompletion:(loadSuccess) completed
                          failure:(loadFailure) failed;

-(void) getListOfUserLikesWithCompletion:(loadSuccess) completed
                                 failure:(loadFailure) failed;

-(void) getFriendsListWithCompletion:(loadSuccess) completed
                             failure:(loadFailure) failed;


@end
