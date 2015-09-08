//
//  NSDictionary+HODictionary.m
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import "NSDictionary+HODictionary.h"

@implementation NSDictionary (HODictionary)

- (id)objectForKeyWithValidation:(NSString *)aKey forExpectedClass:(Class)className {
    
    id value = [self objectForKeyWithValidation:aKey];
    
    if (![value isKindOfClass:className]) {
        return [className new];
    }
    
    else
        return value;
}

- (id)objectForKeyWithValidation:(NSString *)aKey {
    
    id value = [self objectForKey:aKey];
    
    if ([value isKindOfClass:[NSNull class]] || [value isKindOfClass:nil] ||
        ![[self allKeys] containsObject:aKey]) {
        return [NSString new];
    }
    
    else
        return value;
}

@end
