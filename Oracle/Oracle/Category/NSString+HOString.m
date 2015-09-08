//
//  NSString+HOString.m
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+HOString.h"

@implementation NSString (HOString)

- (NSString *)SMString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL, (__bridge CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 kCFStringEncodingUTF8));
}

- (NSString *)encodeString:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL, (CFStringRef)self, NULL, (CFStringRef) @";/?:@&=$+{}<>,",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (NSString *)encodeString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL, (CFStringRef)self, NULL, (CFStringRef) @";/?:@&=$+{}<>,",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (NSString *)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString
            stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (NSString *)extractGetParameter:(NSString *)parameterName {
    NSMutableDictionary *mdQueryStrings = [[NSMutableDictionary alloc] init];
    NSString *url = [[self componentsSeparatedByString:@"?"] objectAtIndex:1];
    for (NSString *qs in [url componentsSeparatedByString:@"&"]) {
        [mdQueryStrings
         setValue:[[[[qs componentsSeparatedByString:@"="] objectAtIndex:1]
                    stringByReplacingOccurrencesOfString:@"+"
                    withString:@" "]
                   stringByReplacingPercentEscapesUsingEncoding:
                   NSUTF8StringEncoding]
         forKey:[[qs componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    return [mdQueryStrings objectForKey:parameterName];
}

- (NSString *)toBase64String {
    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    return base64Encoded;
}

- (NSString *)fromBase64String {
    NSData *nsdataFromBase64String =
    [[NSData alloc] initWithBase64EncodedString:self options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded =
    [[NSString alloc] initWithData:nsdataFromBase64String
                          encoding:NSUTF8StringEncoding];
    return base64Decoded;
}

- (BOOL)isBase64Data {
    if ([self length] % 4 == 0) {
        static NSCharacterSet *invertedBase64CharacterSet = nil;
        if (invertedBase64CharacterSet == nil) {
            invertedBase64CharacterSet =
            [[NSCharacterSet characterSetWithCharactersInString:
              @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs"
              @"tuvwxyz0123456789+/="] invertedSet];
        }
        return
        [self rangeOfCharacterFromSet:invertedBase64CharacterSet
                              options:NSLiteralSearch].location == NSNotFound;
    }
    return NO;
}

- (NSString *)utf8AndURLEncode {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL, (CFStringRef)self, NULL, (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

+ (NSString *)getUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr =
    (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}

+ (NSString *)getNonce {
    // uuid is simplified a bit, also the full uuid can be used as nonce
    NSString *uuid = [self getUUID];
    return [[uuid substringToIndex:10] stringByReplacingOccurrencesOfString:@"-"
                                                                 withString:@""]
    .lowercaseString;
}

- (BOOL)isAlphaNumeric {
    NSCharacterSet *blockCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:blockCharacters].location == NSNotFound);
}

@end
