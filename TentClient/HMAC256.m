//
//  HMAC256.m
//  TentClient
//
//  Created by Dustin Rue on 9/24/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "HMAC256.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation HMAC256

+ (NSString *)HMAC256:(NSString *)data withKey:(NSString *)key
{    
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    return hash;
}
@end
