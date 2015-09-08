//
//  NSDictionary+HODictionary.h
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HODictionary)

- (id)objectForKeyWithValidation:(NSString *)aKey;
- (id)objectForKeyWithValidation:(NSString *)aKey forExpectedClass:(Class)className;

@end
