//
//  AccountManager.h
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *accounts;
@property (nonatomic, strong) NSMutableArray *history;
@property (nonatomic, strong) NSDictionary *query;

+ (instancetype) sharedInstance;

- (void) restoreFromArchive;
- (void) saveToArchive;

@end
