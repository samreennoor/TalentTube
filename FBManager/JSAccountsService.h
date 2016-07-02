//
//  JSAccountsService.h
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^loadAccSuccess)(id data);
typedef void (^loadAccFailure)(NSError *error);


@interface JSAccountsService : NSObject

-(void) postMessageOnWall:(NSString *) message
                completed:(loadAccSuccess) completed
                   failed:(loadAccFailure) failed;


-(void) getUserInfoWithcompleted:(loadAccSuccess)completed
                          failed:(loadAccFailure)failed;

@end
