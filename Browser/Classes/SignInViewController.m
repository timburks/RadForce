//
//  SignInViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import "SignInViewController.h"
#import "SFConnection.h"
#import "RadHTTPHelpers.h"
#import "RadHTTPClient.h"
#import "RadHTTPResult.h"

@interface SignInViewController ()
@end

@implementation SignInViewController

- (void) signInWithKeyRing:(id)sender
{
    if (![[SFConnection sharedInstance] authenticateWithKeyRing]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No KeyRing found"
                              message:@"We were unable to find an app that could handle your signin request."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) signInWithSafari:(id)sender
{
    if (![[SFConnection sharedInstance] authenticateWithSafariUsingCallbackPath:@"mysampleapp://auth/success"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Unable to open Safari"
                              message:@"We were unable to use Safari to make your signin request."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) signInWithLocalCredentials:(id) sender
{
    NSMutableURLRequest *authenticationRequest =
    [[SFConnection sharedInstance] authenticateWithUsername:@"USERNAME"
                                                   password:@"PASSWORD"
                                              securityToken:@"SECURITYTOKEN"];
    [RadHTTPClient connectWithRequest:authenticationRequest
                    completionHandler:^(RadHTTPResult *result) {
                        if (result.statusCode == 200) {
                            [[SFConnection sharedInstance] finishAuthenticatingWithResponse:result.response
                                                                                       data:result.data
                                                                                      error:result.error];
                            [self dismissViewControllerAnimated:YES completion:NULL];
                        }
                    }];
}

@end
