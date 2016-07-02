//
//  JSUser.h
//  FacebookManager
//
//  Created by JayD on 18/08/2015.
//  Copyright (c) 2015 Junaid Sidhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSUser : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * birthday;
@property (nonatomic, strong) NSString * gender;
@property (nonatomic, strong) NSString * facebookID;
@property (nonatomic, strong) NSString * imageURL;
@property (nonatomic, strong) NSString * session;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

+ (NSString *) validStringForObject:(NSString *) object;

@end
