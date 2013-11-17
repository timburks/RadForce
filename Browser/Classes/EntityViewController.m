//
//  EntityViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "EntityViewController.h"
#import "ItemViewController.h"

@interface EntityViewController ()
@property (nonatomic, strong) NSArray *sortedKeys;
@end

@implementation EntityViewController

- (void) loadView
{
    [super loadView];
    self.navigationItem.title = [self.entity objectForKey:@"Name"];
    self.sortedKeys = [[self.entity allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sortedKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    
    NSString *key = [self.sortedKeys objectAtIndex:[indexPath row]];
    id object = [self.entity objectForKey:key];
    
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", object];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.sortedKeys objectAtIndex:[indexPath row]];
    ItemViewController *itemViewController = [[ItemViewController alloc] init];
    itemViewController.entity = self.entity;
    itemViewController.schema = self.schema;
    itemViewController.key = key;
    [[self navigationController] pushViewController:itemViewController animated:YES];
}

@end
