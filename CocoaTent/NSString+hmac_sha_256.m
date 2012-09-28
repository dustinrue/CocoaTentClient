//
//  NSString+hmac_sha_256.m
//  TentClient
//
//  Created by Dustin Rue on 9/25/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
// Based on input from http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1
// and https://github.com/nicklockwood/Base64

#import "NSString+hmac_sha_256.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (hmac_sha_256)

- (NSString *) hmac_sha_256:(NSString *) key
{
    /*
    NSLog(@"signing \n%@", self);
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return [hash base64EncodedString];
     */
    
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedString];
    
    return hash;
}
@end
