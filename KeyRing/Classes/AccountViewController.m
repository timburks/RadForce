//
//  AccountViewController.m
//  KeyRing
//
//  Created by Tim Burks on 4/18/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "AccountViewController.h"
#import "NSDictionary_Ordering.h"
#import "DictionaryViewController.h"
#import "AppDelegate.h"
@interface AccountViewController ()
@property (nonatomic, strong) UIButton *signinButton;
@end

@implementation AccountViewController
@synthesize signinButton = _signinButton;

- (id)init 
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setTableFooter {
    /*
    if (DELEGATE.query) {
        UIView *buttonBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,60)];
        buttonBox.backgroundColor = self.navigationController.navigationController.navigationBar.tintColor;
        self.signinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        NSString *consumerName = [[DELEGATE.query objectForKey:@"requester"] objectForKey:@"name"];                
        [self.signinButton setTitle:[NSString stringWithFormat:@"Sign into %@", consumerName] forState:UIControlStateNormal];
        [self.signinButton addTarget:self action:@selector(signinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.signinButton.frame = CGRectInset(buttonBox.bounds, 10, 10);
        [buttonBox addSubview:self.signinButton];
        self.tableView.tableFooterView = buttonBox;
    } else {
        self.tableView.tableFooterView = nil;
    }
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setTableFooter];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) || 
            (interfaceOrientation == UIInterfaceOrientationPortrait));
}

- (void) signinButtonPressed:(id) sender
{
    [self finishEditingTextFields];
    [self.tableView setEditing:NO animated:YES];
  //  [DELEGATE signInWithAccount:self.dictionary withName:self.name];
}


@end
