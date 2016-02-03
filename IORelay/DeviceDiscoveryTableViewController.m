//
//  DeviceDiscoveryTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/12/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "DeviceDiscoveryTableViewController.h"
#import "DeviceSettingsTableViewController.h"
#import "Device+Access.h"
#import "DiscoveredDevice+Access.h"
#import "UDPCommunications.h"
#import "CommonRoutines.h"
#import "MBProgressHUD.h"


@interface DeviceDiscoveryTableViewController ()

@property (nonatomic, strong) NSString *currentNetworkSSID;

@end

@implementation DeviceDiscoveryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setContext:(NSManagedObjectContext *)context
{
    if (self.managedObjectContext != context) {
        self.managedObjectContext = context;
        
        // Update the view.
        [self configureView];
    }
    
}

- (IBAction)addButtonPressed:(id)sender {
    
    [self.detailViewController setManagedObjectContext:self.managedObjectContext];
    [self.detailViewController setCalledBy:@"Discovery"];
    
    [self.navigationController popViewControllerAnimated:YES];

}

// refresh if were on an iPad
- (void)configureView
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [self.tableView reloadData];
        
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityIndicator) name:@"ShowDiscoveryActivityIndicator" object:nil];
    
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideActivityIndicator) name:@"HideDiscoveryActivityIndicator" object:nil];
    
    // delete old discovered devices
    [DiscoveredDevice deleteAllDiscoveredDevicesInContext:self.managedObjectContext];
    
    // get the current network SSID
    self.currentNetworkSSID = [[UDPCommunications sharedInstance] getNetworkSSID];
    
    if (self.currentNetworkSSID != nil) {
     
     // pass the managed object context to UPDCommunications so he can save info to core data / start monitoring
     [[UDPCommunications sharedInstance] saveMOC:self.managedObjectContext];

    }
    

}

- (void)showActivityIndicator {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideActivityIndicator {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // refresh the settings view 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfigureSettingsView" object:nil userInfo:nil];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
    
//    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo name];
    return self.currentNetworkSSID == nil? @"No Active Network" : self.currentNetworkSSID;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoveryCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [Device deleteDevice:[self.fetchedResultsController objectAtIndexPath:indexPath] inContext:[self.fetchedResultsController managedObjectContext]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

// this is used for iPad navigation/ iphone is handled in prepareforsegue
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Device *device = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.detailViewController setSelectedDevice:device];
        [self.detailViewController setCalledBy:@"Discovery"];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    DiscoveredDevice *device = (DiscoveredDevice *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // setup multiple lines to allow display of signal strength
    if ([device.type isEqualToString:@"WiFi"]) {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSString *nameLabel = [NSString stringWithFormat:@"%@\n%@",device.name, [[CommonRoutines sharedInstance] convertWiFiSignalStrength:device.signalStrength]];
        
        cell.textLabel.text = nameLabel;

    } else {
        cell.textLabel.text = device.name;

    }
    
    // format macAddress for display
    NSString *macAddress = [[CommonRoutines sharedInstance] formatMacAddress:device.macAddress];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@:%@", macAddress, device.ipAddress, device.port];
}


#pragma mark - Navigation

#pragma mark - Storyboard Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // display device settings
    if ([[segue identifier] isEqualToString:@"DeviceSettings"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DiscoveredDevice *selectedDiscoveredDevice = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        NSDictionary *deviceInfo = @{@"name" : selectedDiscoveredDevice.name,
                                     @"macAddress" : selectedDiscoveredDevice.macAddress,
                                     @"ipAddress" : selectedDiscoveredDevice.ipAddress,
                                     @"networkSSID" : selectedDiscoveredDevice.networkSSID,
                                     @"port" : selectedDiscoveredDevice.port,
                                     @"type" : selectedDiscoveredDevice.type
                                     };
        
        // update core data
        Device *device = [Device createDeviceFrom:deviceInfo InContext:self.managedObjectContext];

        [segue.destinationViewController setSelectedDevice:device];
        [segue.destinationViewController setCalledBy:@"Discovery"];
        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];

        
    } else if ([[segue identifier] isEqualToString:@"CreateDevice"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        DiscoveredDevice *selectedDiscoveredDevice = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
//        NSDictionary *deviceInfo = @{@"name" : selectedDiscoveredDevice.name,
//                                     @"macAddress" : selectedDiscoveredDevice.macAddress,
//                                     @"ipAddress" : selectedDiscoveredDevice.ipAddress,
//                                     @"networkSSID" : selectedDiscoveredDevice.networkSSID,
//                                     @"port" : selectedDiscoveredDevice.port,
//                                     @"type" : selectedDiscoveredDevice.type
//                                     };
//        
//        // update core data
//        Device *device = [Device createDeviceFrom:deviceInfo InContext:[selectedDiscoveredDevice managedObjectContext]];
//        
//        [segue.destinationViewController setSelectedDevice:device];
        [segue.destinationViewController setCalledBy:@"Discovery"];
        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
        
        
    }

    
    
    
}


#pragma mark - Fetched results controller
// boiler plate fetched results controller to handle tableview
// we only need to modify the entity name and sort info -

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DiscoveredDevice" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *ssidSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"networkSSID" ascending:YES];
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[ssidSortDescriptor, nameSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"networkSSID" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;

    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */


@end
