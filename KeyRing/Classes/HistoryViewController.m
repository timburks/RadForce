//
//  HistoryViewController.m
//  KeyRing
//
//  Created by Tim Burks on 4/22/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "NSDictionary_Ordering.h"
#import "AccountManager.h"

@interface NSString (ordered) 
- (NSString *) orderedStringValue;
@end

@implementation NSString (ordered)
- (NSString *) orderedStringValue {return self;}
@end

@interface HistoryViewController ()

@end

@implementation HistoryViewController

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
 //   self.view.backgroundColor = TABLE_BACKGROUND_COLOR;
 //   self.tableView.separatorColor = TABLE_SEPARATOR_COLOR;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Close"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(closeButtonPressed:)];
    
    self.navigationItem.title = @"History";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 100;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) closeButtonPressed:(id) sender 
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[AccountManager sharedInstance].history count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = [[AccountManager sharedInstance].history objectAtIndex:[indexPath row]];
    NSMutableString *historyString = [NSMutableString stringWithFormat:@"%@\n%@ received credentials for '%@'",                           
                                      [item objectForKey:@"time"],
                                      [item objectForKey:@"requester"],
                                      [item objectForKey:@"account"]];
    cell.textLabel.text = historyString;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void) tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[AccountManager sharedInstance].history removeObjectAtIndex:[indexPath row]];
        [tableView endUpdates];
    }    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
      *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
