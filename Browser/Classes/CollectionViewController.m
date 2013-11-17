//
//  CollectionViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "CollectionViewController.h"
#import "EntityViewController.h"
#import "SFConnection.h"
#import "RadHTTP.h"

@interface CollectionViewController () <UIAlertViewDelegate>

@end

@implementation CollectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.navigationItem.title = self.entityName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Create"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(create:)];
}

- (void) create:(id) sender
{
    NSLog(@"create a new instance");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create"
                                                        message:@"Enter the name for this new object"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeAlphabet;
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *name = textField.text;
        NSLog(@"name: %@", name);
        
        NSMutableURLRequest *createRequest =
        [[SFConnection sharedInstance] createObjectWithType:self.entityName
                                                     fields:@{@"Name":name}];

        [RadHTTPClient connectWithRequest:createRequest
                        completionHandler:^(RadHTTPResult *result) {
                            NSLog(@"result: %@", [result object]);
                            
                        }];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text = [[self.rows objectAtIndex:[indexPath row]] objectForKey:@"Name"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *row = [self.rows objectAtIndex:[indexPath row]];
    EntityViewController *entityViewController = [[EntityViewController alloc] init];
    entityViewController.entity = row;
    entityViewController.schema = self.schema;
    [[self navigationController] pushViewController:entityViewController animated:YES];
}
@end
