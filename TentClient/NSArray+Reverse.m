//
//  NSArray+Reverse.m
//  TentClient
//
//  Created by Dustin Rue on 10/3/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
//  From - http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}


@end
