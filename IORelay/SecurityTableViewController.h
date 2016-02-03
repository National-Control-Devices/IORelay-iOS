//
//  SecurityTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device+Access.h"

@interface SecurityTableViewController : UITableViewController <UITextFieldDelegate>


@property (strong, nonatomic) Device *device;

- (void)setSelectedDevice:(Device *)device;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UISwitch *accessSwitch;
@property (strong, nonatomic) IBOutlet UITableViewCell *accessPinCell;
@property (strong, nonatomic) IBOutlet UITextField *accessPinField;
@property (strong, nonatomic) IBOutlet UISwitch *configurationSwitch;
@property (strong, nonatomic) IBOutlet UITableViewCell *configurationPinCell;
@property (strong, nonatomic) IBOutlet UITextField *configurationPinField;
    
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;


@end
