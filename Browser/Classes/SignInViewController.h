//
//  SignInViewController.h
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController

- (IBAction) signInWithKeyRing:(id) sender;
- (IBAction) signInWithSafari:(id) sender;
- (IBAction) signInWithLocalCredentials:(id) sender;

@end
