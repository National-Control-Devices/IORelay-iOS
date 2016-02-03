//
//  MasterViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "DeviceListTableViewController.h"
#import "DeviceSettingsTableViewController.h"
#import "DeviceDiscoveryTableViewController.h"
#import "TCPCommunications.h"
#import "CommonRoutines.h"
#import "MBProgressHUD.h"
#import "UDPCommunications.h"


@implementation DeviceListTableViewController

//// initialization - if were on the ipad set size to popover
//- (void)awakeFromNib
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.clearsSelectionOnViewWillAppear = NO;
//        self.preferredContentSize = CGSizeMake(320.0, 600.0);
//    }
//    [super awakeFromNib];
//}

// view initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    // initialize CommonRoutines so we register to listen for showAlert notifications
    [CommonRoutines sharedInstance];
//
    // pass moc to updComms for device updates / start monitoring
    [[UDPCommunications sharedInstance] saveMOC:self.managedObjectContext];
        
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueControlProcessing) name:@"DeviceCommunicationEstablished" object:nil];
    
    // set left button to edit table
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    //if were on an ipad set deviceSettings and DeviceControl as detail view controllers
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        // save off the original splitview configurations
        self.settingsDetailView = [NSArray arrayWithArray:self.splitViewController.viewControllers];
        
        self.controlViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"ControlTableViewController"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.controlViewController];
        
        // create control splitview config
        self.controlDetailView = @[[self.splitViewController.viewControllers objectAtIndex:0], navController];
        
        // set detail for default
        self.detailViewController = (DeviceSettingsTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        [self.detailViewController setManagedObjectContext:self.managedObjectContext];

    }
    
    // initialize network connection to NO
    self.networkConnectionOK = NO;
    
//    // Listen for Relay Control to tell us to update relays
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActivityIndicator) name:@"ShowActivityIndicator" object:nil];
//    
//    // Listen for Relay Control to tell us to update relays
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideActivityIndicator) name:@"HideActivityIndicator" object:nil];
    
    // When shut down make sure we have the settings view loaded for next launch
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSettings) name:@"QuitApp" object:nil];


}

- (void)showActivityIndicator {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideActivityIndicator {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ipad navigaton for the settings button in the table cell from ipad / iphone uses segue
- (IBAction)settingsButtonPressed:(id)sender {
    
    // get the selected device by cell where the i button was pressed
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    self.selectedDevice = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if (self.lastSelectedIndexPath != nil) {
        [self.tableView deselectRowAtIndexPath:self.lastSelectedIndexPath animated:YES];
    }
    
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    self.lastSelectedIndexPath = indexPath;
    
    if ([self checkConfigurationAccessFor:self.selectedDevice]) {
        // set detailview to deviceSettings
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self showSettings];
        }
        
    }
    
}

- (void)showDeviceControl {
    
    self.splitViewController.viewControllers = self.controlDetailView;
    [self.controlViewController setSelectedDevice:self.selectedDevice];
    
    // tell ControlTableViewController to refresh the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewNeedsUpdate" object:nil];

    
}

- (void)showSettings {
    
    self.splitViewController.viewControllers = self.settingsDetailView;
    
    // pass device infomation to detailView
    [self.detailViewController setSelectedDevice:self.selectedDevice];
    [self.detailViewController setManagedObjectContext:self.managedObjectContext];
    [self.detailViewController setCalledBy:@"DeviceList"];
    
    // refresh the settings view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConfigureSettingsView" object:nil userInfo:nil];


}

#pragma mark - Table View Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if configuration access is locked    
    return [self checkConfigurationAccessFor:(Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath]];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [Device deleteDevice:[self.fetchedResultsController objectAtIndexPath:indexPath] inContext:[self.fetchedResultsController managedObjectContext]];
        self.selectedDevice = nil;
        
        [self showSettings];
        
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
    
    self.lastSelectedIndexPath = indexPath;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        Device *device = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // verify that we have setup something to control
        if ([device.displayRelays boolValue] || [device.displayInputs boolValue] || [device.displayMacros boolValue] ) {
            self.selectedDevice = device;
            [self checkDeviceAccess];

        } else {
            // display message that no information has been configured
            // display error alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Options for Control" message:@"The Device has not been configured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        
    }
    

}

// build the cell for the device
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UILabel *deviceName = (UILabel *)[cell viewWithTag:1];
    deviceName.text = [[object valueForKey:@"name"] description];
   
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // process device access
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *alertTextField = [alertView textFieldAtIndex:0];
            
            if ([alertTextField.text isEqualToString:self.selectedDevice.accessPin]) {
                
                [Device accessUnlocked:self.selectedDevice unlocked:[NSNumber numberWithBool:YES]];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    [self showDeviceControl];
                    
                } else {
                    // perform segue to control interface for iphone
                    [self performSegueWithIdentifier:@"showControl" sender:self];

                    
                }

                
            } else {
                // display error alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pin" message:@"Please enter a valid pin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        
    // process configuration access
    } else {
        if (buttonIndex == 1) {
            UITextField *alertTextField = [alertView textFieldAtIndex:0];
            
            if ([alertTextField.text isEqualToString:self.selectedDevice.configPin]) {
                
                [Device configurationUnlocked:self.selectedDevice unlocked:[NSNumber numberWithBool:YES]];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    
                    // set detailview to deviceSettings
                    [self showSettings];
                
                } else {
                    // perform segue to settings interface for iphone
                    [self performSegueWithIdentifier:@"showSettings" sender:self];
                }
            } else {
                // display error alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pin" message:@"Please enter a valid pin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];

            }
        }

        
    }
}

// if we have an access lock we need to get the pin
- (void)checkDeviceAccess {
    
    // if we have returned from the pin check ok then check for reachability
    if ([self checkControlPinAccess]) {
        
        [self checkNetworkConnectivity];
        
    }

}

- (void)checkNetworkConnectivity {
    
    self.networkConnectionOK = NO;
    
    // if we are on the same network as the device test communications with it
    if ([[[TCPCommunications sharedInstance] getNetworkSSID] isEqualToString:self.selectedDevice.networkSSID]) {
        
        // verfify connectivity and get relay status
        [[TCPCommunications sharedInstance] verifyNetworkConnectivityToDevice:self.selectedDevice];
        
        
    // use signalswitch.com to access device
    } else {
    
        [[TCPCommunications sharedInstance] verifySignalSwitchConnectivityToDevice:self.selectedDevice];
        
    }
    
}

- (BOOL)checkControlPinAccess {
    
    if ([self.selectedDevice.accessUnlocked boolValue]) {
        return YES;
    }
    
    BOOL access = NO;
    
    if ([self.selectedDevice.accessSwitch boolValue]) {
        // call view contorller to allow entry of pin
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pin" message:@"Please enter the access pin" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 1;
        
        [alert addButtonWithTitle:@"Go"];
        
        [alert show];
        
    } else {
        access = YES;
    }
    
    return access;

    
    
}

// if we have an access lock we need to get the pin
- (BOOL)checkConfigurationAccessFor:(Device *)device {
    
    if ([device.configurationUnlocked boolValue]) {
        return YES;
    }
    
    BOOL access = NO;
    
    if ([device.configSwitch boolValue]) {
        // call view contorller to allow entry of pin
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pin" message:@"Please enter the configuration pin" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 2;
        
        [alert addButtonWithTitle:@"Go"];
        
        [alert show];
        
    } else {
        access = YES;
    }
    
    return access;
    
}

- (void)continueControlProcessing {
    
    self.networkConnectionOK = YES;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      
        [self showDeviceControl];
        
    } else {
        //execute segue programmatically
        [self performSegueWithIdentifier: @"showControl" sender: self];
    }

    
}

// iphone navigation to show control view
// navigation to show settings
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    // if they clicked on the tableview cell we are going to the control view
    if ([identifier isEqualToString:@"showControl"]) {
        
        // get the selected device by the selected tableviewcell
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Device *device = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // verify that we have setup something to control
        if ([device.displayRelays boolValue] || [device.displayInputs boolValue] || [device.displayMacros boolValue] ) {
//            if (![self.selectedDevice isEqual:device]) {
                self.selectedDevice = device;
                self.networkConnectionOK = NO;
//            }
            
            // networkconnectionOk well be set after return from TCPCommunications - verify...
//            if (!self.networkConnectionOK) {
                [self checkDeviceAccess];
                return NO;
                
                // bypass device access and continue - we've already verified access and communications
//            } else {
//                
//                return YES;
//            }
            
        } else {
            // display message that no information has been configured
            // display error alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Options for Control" message:@"The Device has not been configured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }

        
    // else they selected the button in the cell for settings
    } else if ([identifier isEqualToString:@"showSettings"]) {
        
        
        // get the selected device by cell where the i button was pressed
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        self.selectedDevice = (Device *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            [self showSettings];
            
        }


        return [self checkConfigurationAccessFor:self.selectedDevice];

    } else if ([identifier isEqualToString:@"AddDevice"]) {
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            // we are searching for devices so blank out the settings screen
            self.selectedDevice = nil;
            
            [self showSettings];
            
        }

    
    }
    return YES;
}

// segues to Settings/Add Device/Control views
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // display device settings
    if ([[segue identifier] isEqualToString:@"showSettings"]) {
        
        [segue.destinationViewController setSelectedDevice:self.selectedDevice];
        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
        [segue.destinationViewController setCalledBy:@"DeviceList"];
        
    // display discovery
    } else if ([[segue identifier] isEqualToString:@"AddDevice"]) {
        [segue.destinationViewController setContext:[self.fetchedResultsController managedObjectContext]];
        [segue.destinationViewController setDetailViewController:self.detailViewController];
        
//        [segue.destinationViewController setSelectedDevice:nil];

        
    // display device control
    } else if ([[segue identifier] isEqualToString:@"showControl"]) {
        
        [segue.destinationViewController setSelectedDevice:self.selectedDevice];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Device" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    // If you have sections the first sort needs to match
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
