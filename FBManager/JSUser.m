//
//  JSUser.m
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import "JSUser.h"

@implementation JSUser

+ (NSString *) validStringForObject:(NSString *) object{
    
    if (object)
        return object;
    
    return @"";
}

@end
