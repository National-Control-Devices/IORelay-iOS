//
//  DeviceDiscoveryTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/12/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceSettingsTableViewController;
@class Device;

@interface DeviceDiscoveryTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DeviceSettingsTableViewController *detailViewController;

//@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)setContext:(NSManagedObjectContext *)context;


@end
