//
//  NSDictionary_Ordering.m
//  KeyRing
//
//  Created by Tim Burks on 4/18/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "NSDictionary_Ordering.h"


@implementation NSDictionary (Ordering) 

- (NSArray *) orderedKeys
{
    id keys = [self objectForKey:@"_keys"];
    if (!keys) {        
        keys = [[self allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    }
    return keys;
}

- (NSString *) orderedStringValue 
{
    NSMutableString *string = [NSMutableString string];
    for (id key in [self orderedKeys]) {
        id value = [self objectForKey:key];
        NSString *stringToAppend = nil;
        if ([value isKindOfClass:[NSDictionary class]]) {
            stringToAppend = [value orderedStringValue];
        } else {
            stringToAppend = value;
        }
        if ([stringToAppend length]) {
            [string appendString:stringToAppend];
            [string appendString:@" "];
        }        
    }        
    return string;   
}
@end

