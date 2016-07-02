//
//  JSFBKitService.h
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSFbConstants.h"

typedef void (^loadKitSuccess)(id data);
typedef void (^loadKitFailure)(NSError *error);

@interface JSFBSdkService : NSObject


-(void) getUserInfoWithcompleted:(loadKitSuccess)completed
                          failed:(loadKitFailure)failed;

-(void) postMessageOnWall:(NSString *) message
                completed:(loadKitSuccess) completed
                   failed:(loadKitFailure) failed;

@end
