//
//  AccountManager.m
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import "AccountManager.h"

@implementation AccountManager

+ (instancetype) sharedInstance
{
    static id instance = nil;
    if (!instance) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (instancetype) init
{
    if (self = [super init]) {
        self.accounts = [NSMutableDictionary dictionary];
        [self.accounts setObject:[NSMutableArray array] forKey:@"_keys"];
        self.history = [NSMutableArray array];
    }
    return self;
}

+ (NSString *) cacheDirectory {
    static NSString *_cacheDirectory = nil;
    if (!_cacheDirectory) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDirectory = [paths objectAtIndex:0];
    }
    return _cacheDirectory;
}

- (NSString *) historyFileName
{
    return [[AccountManager cacheDirectory] stringByAppendingPathComponent:@"history.plist"];
}


- (NSString *) accountsFileName
{
    return [[AccountManager cacheDirectory] stringByAppendingPathComponent:@"accounts.plist"];
}

- (void) restoreFromArchive
{
    NSData *historyData = [NSData dataWithContentsOfFile:[self historyFileName]];
    if (historyData) {
        self.history = [NSPropertyListSerialization propertyListWithData:historyData
                                                                 options:NSPropertyListMutableContainersAndLeaves
                                                                  format:nil
                                                                   error:nil];
    } else {
        self.history = [NSMutableArray array];
    }
    
    NSData *accountsData = [NSData dataWithContentsOfFile:[self accountsFileName]];
    if (accountsData) {
        self.accounts = [NSPropertyListSerialization propertyListWithData:accountsData
                                                                  options:NSPropertyListMutableContainersAndLeaves
                                                                   format:nil
                                                                    error:nil];
    } else {
        self.accounts = [NSMutableDictionary dictionary];
        [self.accounts setObject:[NSMutableArray array] forKey:@"_keys"];
    }
    //[self.navigationController.visibleViewController viewWillAppear:NO];
}

- (void) saveToArchive
{
    NSData *historyData = [NSPropertyListSerialization dataWithPropertyList:self.history
                                                                     format:NSPropertyListXMLFormat_v1_0
                                                                    options:0
                                                                      error:nil];
    [historyData writeToFile:[self historyFileName] atomically:NO];
    
    NSData *accountsData = [NSPropertyListSerialization dataWithPropertyList:self.accounts
                                                                      format:NSPropertyListXMLFormat_v1_0
                                                                     options:0
                                                                       error:nil];
    [accountsData writeToFile:[self accountsFileName] atomically:NO];
    
}

@end
