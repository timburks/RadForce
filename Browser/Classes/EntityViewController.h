//
//  EntityViewController.h
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntityViewController : UITableViewController
@property (nonatomic, strong) NSMutableDictionary *entity;
@property (nonatomic, strong) NSDictionary *schema;
@end
