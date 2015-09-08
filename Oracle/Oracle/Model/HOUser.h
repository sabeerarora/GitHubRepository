//
//  HOUser.h
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOUser : NSObject

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *dob;
@property (nonatomic,assign) float weight;
@property (nonatomic,assign) float height;
@property (nonatomic,assign) int gender;

@property (nonatomic,strong) NSDictionary *dateCreated;
@property (nonatomic,strong) NSDictionary *dateUpdated;


-(instancetype)initWithDictionary:(NSDictionary *)dict;
@end
