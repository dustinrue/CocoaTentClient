//
//  NSMutableArray+Reverse.m
//  TentClient
//
//  Created by Dustin Rue on 10/3/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
//  From - http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c

#import "NSMutableArray+Reverse.h"

@implementation NSMutableArray (Reverse)

- (void)reverse
{
    if ([self count] == 0)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end
