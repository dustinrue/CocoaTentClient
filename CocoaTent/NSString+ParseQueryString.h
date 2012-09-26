//
//  NSString+ParseQueryString.h
//  TentClient
//
//  Created by Dustin Rue on 9/24/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ParseQueryString)

- (NSMutableDictionary *)explodeToDictionaryInnerGlue:(NSString *)innerGlue outterGlue:(NSString *)outterGlue;

@end
