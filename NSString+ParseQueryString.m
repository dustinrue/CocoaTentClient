//
//  NSString+ParseQueryString.m
//  TentClient
//
//  Created by Dustin Rue on 9/24/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NSString+ParseQueryString.h"

@implementation NSString (ParseQueryString)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue {
    // Explode based on outter glue
    NSArray *firstExplode = [self componentsSeparatedByString:outterGlue];
    NSArray *secondExplode;
    
    // Explode based on inner glue
    NSInteger count = [firstExplode count];
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        secondExplode = [(NSString *)[firstExplode objectAtIndex:i] componentsSeparatedByString:innerGlue];
        if ([secondExplode count] == 2) {
            [returnDictionary setObject:[secondExplode objectAtIndex:1] forKey:[secondExplode objectAtIndex:0]];
        }
    }
    
    return returnDictionary;
}

@end

