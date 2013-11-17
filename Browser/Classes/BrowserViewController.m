//
//  BrowserViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//
#import "BrowserViewController.h"

#import "RadHTTP.h"
#import "SFConnection.h"
#import "SignInViewController.h"
#import "CollectionViewController.h"

@interface BrowserViewController ()
@property (nonatomic, strong) NSArray *dataRows;
@end

@implementation BrowserViewController

#pragma mark - View lifecycle
- (void) loadView
{
    [super loadView];
    self.title = @"Force Browser";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"sign out"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(signOut:)];
    [self refreshContents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshContents];
}

#pragma mark - View data management

- (void) refreshContents
{
    if ([[SFConnection sharedInstance] isAuthenticated]) {
        NSMutableURLRequest *queryRequest = [[SFConnection sharedInstance] describeDatabase];
        [RadHTTPClient connectWithRequest:queryRequest completionHandler:^(RadHTTPResult *result) {
            // NSLog(@"RESULTS: %@", [result object]);
            self.dataRows = [[result object] objectForKey:@"sobjects"];
            [self.tableView reloadData];
        }];
    }
}

- (void) signOut:(id) sender
{
    [[SFConnection sharedInstance] signOut];
    [self presentSignInController];
}

- (void) presentSignInController
{
    SignInViewController *signInViewController = [[SignInViewController alloc] init];
    [self presentViewController:signInViewController animated:YES completion:^{}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:CellIdentifier];
    }
    //if you want to add an image to your cell, here's how
    UIImage *image = [UIImage imageNamed:@"icon.png"];
    cell.imageView.image = image;
    
    // Configure the cell to show the data.
    NSDictionary *obj = [self.dataRows objectAtIndex:indexPath.row];
    cell.textLabel.text =  [obj objectForKey:@"name"];
    
    //this adds the arrow to the right hand side.
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)itemTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [itemTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *obj = [self.dataRows objectAtIndex:indexPath.row];
    NSString *entityName =  [obj objectForKey:@"name"];
    // get information about this entity
    
    NSMutableURLRequest *request = [[SFConnection sharedInstance]
                                    describeDatabaseType:entityName];
    [RadHTTPClient connectWithRequest:request
                    completionHandler:^(RadHTTPResult *result) {                        
                        if (![[[result object] objectForKey:@"queryable"] intValue]) {
                            UIAlertView *alert = [[UIAlertView alloc]
                                                  initWithTitle:@"Sorry"
                                                  message:@"This entity does not support queries"
                                                  delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
                            [alert show];
                        } else {
                            NSDictionary *schema = [result object];
                            
                            NSMutableArray *fieldNames = [NSMutableArray array];
                            for (id field in [schema objectForKey:@"fields"]) {
                                [fieldNames addObject:[field objectForKey:@"name"]];
                            }
                            
                            NSString *queryString = [NSString stringWithFormat:@"SELECT %@ FROM %@ LIMIT 100",
                                                     [fieldNames componentsJoinedByString:@","],
                                                     entityName];
                            NSDictionary *query = @{@"q":queryString};
                            NSMutableURLRequest *queryRequest = [[SFConnection sharedInstance] queryRequestWithArguments:query];
                            RadHTTPClient *client = [[RadHTTPClient alloc] initWithRequest:queryRequest];
                            [client connectWithCompletionHandler:^(RadHTTPResult *result) {
                                NSLog(@"%@", [result object]);
                                
                                CollectionViewController *collectionViewController = [[CollectionViewController alloc] initWithStyle:UITableViewStylePlain];
                                collectionViewController.entityName = entityName;
                                collectionViewController.schema = schema;
                                collectionViewController.rows = [[result object] objectForKey:@"records"];
                                [[self navigationController] pushViewController:collectionViewController animated:YES];
                            }];
                        }
                    }];    
}

@end
