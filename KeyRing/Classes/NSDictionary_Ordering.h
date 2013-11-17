//
//  NSDictionary_Ordering.h
//  KeyRing
//
//  Created by Tim Burks on 4/18/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Ordering)
- (NSArray *) orderedKeys;
- (NSString *) orderedStringValue;
@end
