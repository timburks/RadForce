//
//  CreateAccountViewController.h
//  KeyRing
//
//  Created by Tim Burks on 4/22/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "DictionaryViewController.h"

@class AccountsViewController;

@interface CreateAccountViewController : DictionaryViewController
@property (nonatomic, weak) AccountsViewController *accountsViewController;

- (void)initializeAccount;
@end
