//
//  CreateAccountViewController.m
//  KeyRing
//
//  Created by Tim Burks on 4/22/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "AccountViewController.h"
#import "AccountsViewController.h"
#import "AppDelegate.h"
#import "RadAlertView.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    // self.view.backgroundColor = TABLE_BACKGROUND_COLOR;
    // self.tableView.separatorColor = TABLE_SEPARATOR_COLOR;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Cancel"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(closeButtonPressed:)];
    
    self.navigationItem.title = @"Add An Account";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Create"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(createButtonPressed:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#define INITIAL_ACCOUNT_NAME @"username@domain"

- (void)initializeAccount
{
    self.dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:INITIAL_ACCOUNT_NAME,
                       @"The email address associated with your account", nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) closeButtonPressed:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void) createButtonPressed:(id) sender
{
    [self finishEditingTextFields];
    
    NSString *key = [[self keys] objectAtIndex:0];
    NSString *name = [self.dictionary objectForKey:key];
    if ([name isEqualToString:INITIAL_ACCOUNT_NAME] || ([name length] == 0)) {
        RadAlertView *alert = [RadAlertView
                               alertWithTitle:@"Name This Account"
                               message:@"Please enter an email address for your account."
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
        [alert show];
        [self textFieldTappedForCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }
    
    else if ([self.accountsViewController addAccountWithName:name]) {
        [self.accountsViewController displayAccountWithName:name];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
}

- (void)textFieldTappedForCell:(UITableViewCell *) cell
{
    [super textFieldTappedForCell:cell];
    UITextField *editableTextField = (UITextField *) [cell viewWithTag:100];
    editableTextField.text = @"";
}

@end
