//
//  DictionaryViewController.m
//  KeyRing
//
//  Created by Tim Burks on 4/18/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

#import "DictionaryViewController.h"
#import "NSDictionary_Ordering.h"
#import "RadAlertView.h"
#import "AppDelegate.h"

#define EDIT_MARGIN 10

@interface DictionaryTableViewCell : UITableViewCell

@end

@implementation DictionaryTableViewCell

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    UITextField *editableTextField = (UITextField *) [self viewWithTag:100];    
    [editableTextField resignFirstResponder];
    [super setEditing:editing animated:animated];
}

@end

@interface DictionaryViewController ()
@property (nonatomic, weak) UITextField *activeTextField;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;
@end

@implementation DictionaryViewController

- (id)init 
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.tableView.rowHeight = 80;
    
   // self.view.backgroundColor = TABLE_BACKGROUND_COLOR;
   // self.tableView.separatorColor = TABLE_SEPARATOR_COLOR;
    
    self.doneButtonItem = [[UIBarButtonItem alloc]
                           initWithTitle:@"Done" 
                           style:UIBarButtonItemStyleDone
                           target:self
                           action:@selector(doneButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                       target:self 
                                                                       action:@selector(toolbarButtonPressed:)],
                         nil];
    
    self.keyboardIsVisible = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    self.title = self.name;
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) keyboardWillShow:(id) notification {
    if (self.keyboardIsVisible) 
        return;
    self.keyboardIsVisible = YES;
    
    UITableViewCell *cell = (UITableViewCell *) [self.activeTextField superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSDictionary *info = [notification userInfo];
    NSValue *frameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [frameValue CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height -= (keyboardSize.height);
    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom 
                                  animated:YES];    
}

- (void) keyboardWillHide:(id) notification {
    if (!self.keyboardIsVisible)
        return;
    self.keyboardIsVisible = NO;

    NSDictionary *info = [notification userInfo];
    NSValue *frameValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [frameValue CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height += (keyboardSize.height);
    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) || 
            (interfaceOrientation == UIInterfaceOrientationPortrait));
}

- (void) toolbarButtonPressed:(id) sender 
{
    
    RadAlertView *alertView = [RadAlertView alertWithTitle:@"Add an attribute"
                                                   message:@"Enter the attribute name here:"
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView._alertView_clickedButtonAtIndex = ^(RadAlertView *alertView, NSInteger index) {
        if (index == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *key = textField.text;    
            [self.dictionary setObject:@"" forKey:key];
            [[self.dictionary objectForKey:@"_keys"] addObject:key];
            [self.tableView reloadData];            
        }
    };
    [alertView show];      
}

- (NSArray *) keys {
    return [self.dictionary orderedKeys];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self keys] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[DictionaryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITextField *editableTextField = [[UITextField alloc] initWithFrame:cell.textLabel.frame];
        editableTextField.tag = 100;
        editableTextField.delegate = self;
        [cell addSubview:editableTextField];
    }
    return cell;
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
    [self finishEditingTextFields];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
        NSString *key = [[self keys] objectAtIndex:[indexPath row]];
        [self.dictionary removeObjectForKey:key];
        [[self.dictionary objectForKey:@"_keys"] removeObject:key];        
        [tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString *key = [[self keys] objectAtIndex:row];
    id value = [self.dictionary objectForKey:key];
    cell.textLabel.text = key;
    UITextField *editableTextField = (UITextField *) [cell viewWithTag:100];
    editableTextField.hidden = YES;
    cell.detailTextLabel.alpha = 1.0;
    if ([value isKindOfClass:[NSArray class]]) {
        cell.detailTextLabel.text = @"array";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        cell.detailTextLabel.text = [value orderedStringValue];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        if (value && [value length]) {
            cell.detailTextLabel.text = value;
        } else {
            cell.detailTextLabel.text = @" ";
        }
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
}

- (void)textFieldTappedForCell:(UITableViewCell *) cell
{
    cell.detailTextLabel.alpha = 0.1;
    UITextField *editableTextField = (UITextField *) [cell viewWithTag:100];
    
    CGRect editFrame = cell.detailTextLabel.frame;
    editFrame.size.width = cell.bounds.size.width - editFrame.origin.x - EDIT_MARGIN;
    editableTextField.frame = editFrame;
    editableTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    if ([cell.detailTextLabel.text isEqualToString:@" "]) {
        editableTextField.text = @"";
    } else {
        editableTextField.text = cell.detailTextLabel.text;
    }
    editableTextField.font = cell.detailTextLabel.font;
    editableTextField.hidden = NO;
    [cell bringSubviewToFront:editableTextField];
    [editableTextField becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self finishEditingTextFields];
    NSInteger row = [indexPath row];
    NSString *key = [[self keys] objectAtIndex:row];
    id value = [self.dictionary objectForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        DictionaryViewController *dictionaryViewController = [[DictionaryViewController alloc] init];
        dictionaryViewController.name = @"Account";
        dictionaryViewController.header = [[self.name stringByAppendingString:@" "] stringByAppendingString:key];
        dictionaryViewController.dictionary = value;
        [self.navigationController pushViewController:dictionaryViewController animated:YES];
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self textFieldTappedForCell:cell];
    }
}

- (void) finishEditingTextFields 
{
    [self.activeTextField resignFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField 
{
    
    self.activeTextField = textField;
    if (self.navigationItem.rightBarButtonItem == self.editButtonItem) {
        self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    }
}

- (void) doneButtonPressed:(id) sender 
{
    [self finishEditingTextFields];
}

- (void) textFieldDidEndEditing:(UITextField *)textField 
{
    id parent = [textField superview];
    while (parent && ![parent isKindOfClass:[DictionaryTableViewCell class]]) {
        parent = [parent superview];
    }
    if (!parent) {
        return; // bad
    }
    UITableViewCell *cell = (UITableViewCell *) parent;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *key = [[self keys] objectAtIndex:[indexPath row]];
    
    cell.detailTextLabel.alpha = 1.0;
    textField.hidden = YES;
    
    if (![[self.dictionary objectForKey:key] isEqualToString:textField.text]) {        
        [self.dictionary setObject:textField.text forKey:key];   
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];        
    }
    
    self.activeTextField = nil;
    if (self.navigationItem.rightBarButtonItem == self.doneButtonItem) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

