//
//  AccountsViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import "AccountsViewController.h"
#import "CreateAccountViewController.h"
#import "HistoryViewController.h"
#import "AccountViewController.h"
#import "AccountManager.h"
#import "NSDictionary_Ordering.h"
#import "RadAlertView.h"
#import "SFConnection.h"
#import "RadHTTP.h"
#import "OAuthSignInViewController.h"

@interface AccountsViewController ()
@property (nonatomic, strong) CreateAccountViewController *createAccountViewController;
@property (nonatomic, strong) UINavigationController *createAccountNavigationController;
@property (nonatomic, strong) HistoryViewController *historyViewController;
@property (nonatomic, strong) UINavigationController *historyNavigationController;
@property (nonatomic, strong) NSString *selectedKey;
@end

static NSString *CellIdentifier = @"Cell";

@implementation AccountsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Key Ring";
        [self.tableView registerClass:[UITableViewCell class]
               forCellReuseIdentifier:CellIdentifier];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(addButtonPressed:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:NULL],
                         [[UIBarButtonItem alloc] initWithTitle:@"OAuth"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(signInWithOAuth:)],
                         nil];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"History"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(historyButtonPressed:)];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addButtonPressed:(id) sender
{
    if (!self.createAccountViewController) {
        self.createAccountViewController = [[CreateAccountViewController alloc] init];
        self.createAccountViewController.accountsViewController = self;
    }
    if (!self.createAccountNavigationController) {
        self.createAccountNavigationController = [[UINavigationController alloc]
                                                  initWithRootViewController:self.createAccountViewController];
        // self.createAccountNavigationController.navigationBar.tintColor = TINT_COLOR;
    }
    [self.createAccountViewController initializeAccount];
    [self presentViewController:self.createAccountNavigationController animated:YES completion:^{}];
}

- (void) historyButtonPressed:(id) sender
{
    if (!self.historyViewController) {
        self.historyViewController = [[HistoryViewController alloc] init];
    }
    if (!self.historyNavigationController) {
        self.historyNavigationController = [[UINavigationController alloc]
                                            initWithRootViewController:self.historyViewController];
        // self.historyNavigationController.navigationBar.tintColor = TINT_COLOR;
    }
    [self presentViewController:self.historyNavigationController animated:YES completion:^{}];
}

- (void) signInWithOAuth:(id) sender
{
    OAuthSignInViewController *oAuthSignInViewController = [[OAuthSignInViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:oAuthSignInViewController];
    [self presentViewController:navigationController animated:YES completion:^{
        
    }];
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
    return [[AccountManager sharedInstance].accounts count]-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *key = [[self keys] objectAtIndex:[indexPath row]];
    id value = [[AccountManager sharedInstance].accounts objectForKey:key];
    cell.textLabel.text = key;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.detailTextLabel.text = [value description];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Accounts";
}

- (NSArray *) keys {
    return [[AccountManager sharedInstance].accounts orderedKeys];
}

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
        NSString *key = [[self keys] objectAtIndex:[indexPath row]];
        [[AccountManager sharedInstance].accounts removeObjectForKey:key];
        [[[AccountManager sharedInstance].accounts objectForKey:@"_keys"] removeObject:key];
        [tableView endUpdates];
    }
}

// Override to support rearranging the table view.
- (void)___tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
         toIndexPath:(NSIndexPath *)toIndexPath
{
    
}

- (BOOL) addAccountWithName:(NSString *) name
{
    if ([[AccountManager sharedInstance].accounts objectForKey:name]) {
        return NO;
    } else {
        NSMutableDictionary *account = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"", @"password",
                                        @"", @"security token",
                                        nil];
        [[AccountManager sharedInstance].accounts setObject:account forKey:name];
        [[[AccountManager sharedInstance].accounts objectForKey:@"_keys"] addObject:name];
        return YES;
    }
}

- (void) displayAccountWithName:(NSString *) name
{
    AccountViewController *accountViewController = [[AccountViewController alloc] init];
    accountViewController.name = @"Account";
    accountViewController.header = name;
    accountViewController.dictionary = [[AccountManager sharedInstance].accounts objectForKey:name];
    [self.navigationController pushViewController:accountViewController animated:YES];
}

- (void) shareAccountWithSelectedKey {
    id account = [[AccountManager sharedInstance].accounts objectForKey:self.selectedKey];
    
    
    
    id requester = [[AccountManager sharedInstance].query objectForKey:@"requester"];
    NSString *consumerKey = [requester objectForKey:@"consumer key"];
    NSString *consumerSecret = [requester objectForKey:@"consumer secret"];
    
    [[SFConnection sharedInstance] setConsumerKey:consumerKey secret:consumerSecret];
    
    NSMutableURLRequest *authenticationRequest =
    [[SFConnection sharedInstance] authenticateWithUsername:self.selectedKey
                                                   password:[account objectForKey:@"password"]
                                              securityToken:[securityTokens objectForKey:self.selectedKey
                                                             
                                                             ]];
    RadHTTPClient *client = [[RadHTTPClient alloc] initWithRequest:authenticationRequest];
    [client connectWithCompletionHandler:^(RadHTTPResult *result) {
        id error_description = [[result object] objectForKey:@"error_description"];
        if (error_description) {
            RadAlertView *alert = [RadAlertView
                                   alertWithTitle:@"Unable to Authenticate"
                                   message:error_description
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];
        } else {
            [[SFConnection sharedInstance] finishAuthenticatingWithResponse:result.response data:result.data error:result.error];
            NSDictionary *transaction = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [[[AccountManager sharedInstance].query objectForKey:@"requester"] objectForKey:@"name"], @"requester",
                                         self.selectedKey, @"account",
                                         [[NSDate date] description], @"time",
                                         nil];
            [[AccountManager sharedInstance].history insertObject:transaction atIndex:0];
            
            id scheme = [requester objectForKey:@"scheme"];
            if (scheme && [[SFConnection sharedInstance] accessToken]) {
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@:?%@",
                   scheme,
                   [@{@"access_token":[[SFConnection sharedInstance] accessToken],
                      @"instance_url":[[SFConnection sharedInstance] instanceURLPath]}
                    rad_URLQueryString]]]];
            }
        }
    }];
}


- (void) promptUserToShareAccountWithSelectedKey
{
    NSString *consumerName = [[[AccountManager sharedInstance].query objectForKey:@"requester"] objectForKey:@"name"];
    RadAlertView *alert = [RadAlertView
                           alertWithTitle:@"Sign In"
                           message:[NSString stringWithFormat:@"Sign into %@ with your '%@' account.",
                                    consumerName,
                                    self.selectedKey]
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"OK", nil];
    alert._alertView_clickedButtonAtIndex = ^(RadAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self shareAccountWithSelectedKey];
        }
    };
    [alert show];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([AccountManager sharedInstance].query) {
        self.selectedKey = [[self keys] objectAtIndex:[indexPath row]];
        NSInteger selectedIndex = [indexPath row];
        NSString *key = [[self keys] objectAtIndex:selectedIndex];
        NSDictionary *account = [[AccountManager sharedInstance].accounts objectForKey:key];
        if ([account objectForKey:@"PIN"] && [[account objectForKey:@"PIN"] length]) {
            RadAlertView *alertView = [RadAlertView alertWithTitle:@"PIN Required"
                                                           message:@"Enter the PIN number for this account"
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypePhonePad;
            alertView._alertView_clickedButtonAtIndex = ^(RadAlertView *alertView, NSInteger index) {
                if (index == 1) {
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    if ([textField.text isEqualToString:[account objectForKey:@"PIN"]]) {
                        [self shareAccountWithSelectedKey];
                    }
                }
            };
            [alertView show];
        } else {
            [self promptUserToShareAccountWithSelectedKey];
        }
    }
}

NSDictionary *securityTokens = nil;

+ (void) initialize {
    securityTokens = @{@"USERNAME":@"TOKEN"};
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self shareAccountWithSelectedKey];
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selectedIndex = [indexPath row];
    NSString *key = [[self keys] objectAtIndex:selectedIndex];
    NSDictionary *account = [[AccountManager sharedInstance].accounts objectForKey:key];
    if ([account objectForKey:@"PIN"] && [[account objectForKey:@"PIN"] length]) {
        RadAlertView *alertView = [RadAlertView alertWithTitle:@"PIN Required"
                                                       message:@"Enter the PIN number for this account"
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypePhonePad;
        alertView._alertView_clickedButtonAtIndex = ^(RadAlertView *alertView, NSInteger index) {
            if (index == 1) {
                UITextField *textField = [alertView textFieldAtIndex:0];
                if ([textField.text isEqualToString:[account objectForKey:@"PIN"]]) {
                    [self displayAccountWithName:key];
                }
            }
        };
        [alertView show];
    } else {
        [self displayAccountWithName:key];
    }
}

@end
