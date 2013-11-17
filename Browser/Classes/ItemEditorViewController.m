//
//  ItemEditorViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "ItemEditorViewController.h"
#import "SFConnection.h"
#import "RadHTTP.h"

@interface ItemEditorViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIPickerView *pickerView;
@end

@implementation ItemEditorViewController

- (void) loadView
{
    [super loadView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Cancel"
                                             style:UIBarButtonItemStyleDone
                                             target:self
                                             action:@selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Save"
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(save:)];
    
    self.navigationItem.title = @"Edit";
    
    if ([[self.schema objectForKey:@"type"] isEqualToString:@"picklist"]) {
        CGRect pickerFrame = CGRectMake(0,84,
                                        self.view.bounds.size.width,
                                        200);
        self.pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        [self.view addSubview:self.pickerView];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
    } else {
        CGRect textViewFrame = CGRectMake(10, 84,
                                          self.view.bounds.size.width-20,
                                          100);
        self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
        [self.view addSubview:self.textView];
    }
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    id value = [self.entity objectForKey:self.key];
    if ([value isKindOfClass:[NSString class]]) {
        self.textView.text = value;
    }
}

- (void) save:(id) sender
{
    
    id value;
    
    if (self.textView) {
        value = self.textView.text;
    } else if (self.pickerView) {
        int row = [self.pickerView selectedRowInComponent:0];
        NSArray *picklistValues = [self.schema objectForKey:@"picklistValues"];
        value = [[picklistValues objectAtIndex:row] objectForKey:@"value"];        
    }
    
    NSDictionary *fields = [NSDictionary dictionaryWithObjectsAndKeys:
                            value, self.key,
                            nil];
    
    NSString *objectType = [[self.entity objectForKey:@"attributes"]
                            objectForKey:@"type"];
    NSString *objectId = [self.entity objectForKey:@"Id"];
    NSMutableURLRequest *updateRequest = [[SFConnection sharedInstance]
                                          updateObjectWithType:objectType
                                          objectId:objectId
                                          fields:fields];
    
    [RadHTTPClient connectWithRequest:updateRequest completionHandler:^(RadHTTPResult *result) {
        NSLog(@"Code %d", [result statusCode]);
        NSLog(@"RESULT %@", [result UTF8String]);
        
        if ([result statusCode] == 400) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:[[[result object] objectAtIndex:0] objectForKey:@"message"]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        
        NSMutableURLRequest *fetchRequest = [[SFConnection sharedInstance]
                                             fetchObjectWithType:objectType
                                             objectId:objectId];
        [RadHTTPClient connectWithRequest:fetchRequest completionHandler:^(RadHTTPResult *result) {
            NSLog(@"Code %d", [result statusCode]);
            NSLog(@"RESULT %@", [result UTF8String]);
            [self.entity addEntriesFromDictionary:[result object]];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        }];
        
    }];
    
}

- (void) cancel:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *picklistValues = [self.schema objectForKey:@"picklistValues"];
    return [picklistValues count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *picklistValues = [self.schema objectForKey:@"picklistValues"];
    return [[picklistValues objectAtIndex:row] objectForKey:@"label"];
}
@end
