//
//  ItemViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "ItemViewController.h"
#import "ItemEditorViewController.h"

@interface ItemViewController ()
@property (nonatomic, strong) NSDictionary *itemSchema;
@property (nonatomic, strong) NSArray *itemSchemaSortedKeys;
@end

@implementation ItemViewController

- (void) loadView
{
    [super loadView];
    
    self.navigationItem.title = self.key;
    
    for (id field in [self.schema objectForKey:@"fields"]) {
        if ([[field objectForKey:@"name"] isEqualToString:self.key]) {
            self.itemSchema = field;
            self.itemSchemaSortedKeys = [[field allKeys] sortedArrayUsingSelector:@selector(compare:)];
            break;
        }
    }
    
    // is this value editable?
    NSArray *editableTypes = @[@"string", @"textarea", @"url",
                               @"picklist"];
    NSString *type = [self.itemSchema objectForKey:@"type"];
    if ([editableTypes containsObject:type]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:@"Edit"
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(edit:)];
    }
}

- (void) edit:(id) sender
{
    NSLog(@"EDIT THIS ITEM");
    
    ItemEditorViewController *itemEditorViewController = [[ItemEditorViewController alloc] init];
    itemEditorViewController.schema = self.itemSchema;
    itemEditorViewController.entity = self.entity;
    itemEditorViewController.key = self.key;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:itemEditorViewController];
    
    [self presentViewController:navigationController animated:YES completion:NULL];        
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [self.itemSchemaSortedKeys count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.key;
    } else {
        return @"schema";
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 200;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:@"Cell1"];
        cell.textLabel.text = [[self.entity objectForKey:self.key] description];
        cell.textLabel.numberOfLines = 0;
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                       reuseIdentifier:@"Cell2"];
        NSString *schemaKey = [self.itemSchemaSortedKeys objectAtIndex:[indexPath row]];
        cell.detailTextLabel.text = schemaKey;
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.itemSchema objectForKey:schemaKey]];
        return cell;
    }
}

@end
