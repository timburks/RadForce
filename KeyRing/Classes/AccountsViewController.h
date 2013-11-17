//
//  AccountsViewController.h
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsViewController : UITableViewController

- (BOOL) addAccountWithName:(NSString *) name;
- (void) displayAccountWithName:(NSString *) name;

@end
