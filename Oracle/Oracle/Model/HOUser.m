//
//  HOUser.m
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import "HOUser.h"

@implementation HOUser

-(instancetype)initWithDictionary:(NSDictionary *)dict
{
    HOUser *model = [HOUser new];
    
    model.userId = [dict objectForKeyWithValidation:@"objectId"];
    model.dateCreated = [dict objectForKeyWithValidation:@"createdAt"];
    model.dateUpdated = [dict objectForKeyWithValidation:@"updatedAt"];
    model.dob = [dict objectForKeyWithValidation:@"dob"];
    model.gender = [[dict objectForKeyWithValidation:@"gender"] intValue];
    model.height = [[dict objectForKeyWithValidation:@"height"] floatValue];
    model.weight = [[dict objectForKeyWithValidation:@"weight"] floatValue];
    
    return model;
}
@end
