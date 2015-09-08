//
//  NSString+HOString.h
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HOString)

- (NSString *)SMString;
- (NSString *)encodeString:(NSStringEncoding)encoding;
- (NSString *)encodeString;
- (NSString *)md5;
- (NSString *)extractGetParameter:(NSString *)parameterName;
- (NSString *)toBase64String;
- (NSString *)fromBase64String;
- (BOOL)isBase64Data;

- (NSString *)utf8AndURLEncode;
+ (NSString *)getNonce;

- (BOOL)isAlphaNumeric;

@end
