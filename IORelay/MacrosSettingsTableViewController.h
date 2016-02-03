//
//  MacrosSettingsTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/18/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device+Access.h"


@interface MacrosSettingsTableViewController : UITableViewController

@property (strong, nonatomic) Device *device;

- (void)setSelectedDevice:(Device *)device;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
