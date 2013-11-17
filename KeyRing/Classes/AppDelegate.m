//
//  AppDelegate.m
//  KeyRing
//
//  Created by Tim Burks on 11/2/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "RadHTTP.h"
#import "AccountsViewController.h"
#import "AccountManager.h"
#import "RadAlertView.h"

@interface AppDelegate ()
@property (nonatomic, strong) AccountsViewController *accountsViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.accountsViewController = [[AccountsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:self.accountsViewController];
    navigationController.toolbarHidden = NO;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSArray *parts = [[url resourceSpecifier] componentsSeparatedByString:@"?"];
    if ([parts count] > 1) {
        NSDictionary *query = [[parts objectAtIndex:1] rad_URLQueryDictionary];
        NSLog(@"query: %@", query);
        
        NSString *jsonString = [query objectForKey:@"request"];
        
        NSError *error;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        NSLog(@"%@", payload);
        if (query) {
            NSMutableString *message =
            [NSMutableString stringWithFormat:
             @"%@ would like to sign in with a Salesforce account. Select any account from the list and you will be prompted to sign in.",
             [[payload objectForKey:@"requester"] objectForKey:@"name"]];
            RadAlertView *alert = [RadAlertView
                                   alertWithTitle:@"Signin Request"
                                   message:message
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];
            
            [AccountManager sharedInstance].query = payload;
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[AccountManager sharedInstance] saveToArchive];
    [RadAlertView dismissAllAlerts];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[AccountManager sharedInstance] restoreFromArchive];
    [self.accountsViewController.tableView reloadData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
