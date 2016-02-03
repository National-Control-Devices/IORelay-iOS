//
//  MasterViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device+Access.h"
#import "ControlTableViewController.h"

@class DeviceSettingsTableViewController;

#import <CoreData/CoreData.h>

@interface DeviceListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) DeviceSettingsTableViewController *detailViewController;
@property (strong, nonatomic) ControlTableViewController *controlViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) Device *selectedDevice;

@property (strong, nonatomic) NSArray *settingsDetailView;
@property (strong, nonatomic) NSArray *controlDetailView;

@property (nonatomic) BOOL networkConnectionOK;

@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;


@end
