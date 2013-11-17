//
//  ItemViewController.h
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewController : UITableViewController
@property (nonatomic, strong) NSMutableDictionary *entity;
@property (nonatomic, strong) NSDictionary *schema;
@property (nonatomic, strong) NSString *key;
@end
