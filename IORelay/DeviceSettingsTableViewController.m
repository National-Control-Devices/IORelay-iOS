//
//  DetailViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "DeviceSettingsTableViewController.h"
#import "Device+Access.h"
#import "InputTableViewController.h"
#import "SecurityTableViewController.h"
#import "RelayTableViewController.h"
#import "MacrosSettingsTableViewController.h"
#import "CommonRoutines.h"


@interface DeviceSettingsTableViewController ()


@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (nonatomic) BOOL showTypePicker;
@property (strong, nonatomic) NSArray *typePickerChoices;

- (void)configureView;
@end

@implementation DeviceSettingsTableViewController

#pragma mark - Managing the detail item

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//
- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

// force refresh if were on the iPad
- (void)configureView
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        
        [self.tableView reloadData];

    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // set ourself as thedelegate for the textfields
    self.nameField.delegate = self;
    [self.nameField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.macField.delegate = self;
    self.macField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.ipField.delegate = self;
    self.ipField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.portField.delegate = self;
    self.portField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.ssidField.delegate = self;
    self.ssidField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.typePickerView.delegate = self;
    self.typePickerView.dataSource = self;
    
    self.typePickerView.hidden = YES;
    
    self.typePickerChoices = @[@"Ethernet", @"WiFi", @"Webi"];
    
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureSettingsView) name:@"ConfigureSettingsView" object:nil];

}


- (void)configureSettingsView {
    
//    self.device = nil;
    
    [self configureView];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.typeLabel.text = [self.typePickerChoices objectAtIndex:row];
    
    // we made a change so enable save button
    [self.saveButton setEnabled:YES];
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.typePickerChoices objectAtIndex:row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [self.typePickerChoices count];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // disable the save button until a change
    [self.saveButton setEnabled:NO];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// user pressed the save button
- (IBAction)saveDevicePressed:(id)sender {
    
    [self updateDevice];
        
    [self.navigationController popToRootViewControllerAnimated:YES];
    
   
}


#pragma mark - textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
        
    [self.saveButton setEnabled:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Device List", @"Device List");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 6) {
        if (self.showTypePicker) {
            self.typePickerView.hidden = NO;
            return 100.0;
        } else {
            self.typePickerView.hidden = YES;
            return 0.0;
        }
    }
    
    return 44.0;

}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
//}


// load text fields with info from device
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];

                    } else {
                        [cell.contentView setHidden:NO];
                        self.nameField.text = self.device.name;
                        
                    }
                    
                    break;
                }
                case 1: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];
                        
                    } else {
                        [cell.contentView setHidden:NO];
                        self.macField.text = [[CommonRoutines sharedInstance] formatMacAddress:self.device.macAddress];
                        
                    }
                    

                    break;
                }
                case 2: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];
                        
                    } else {
                        [cell.contentView setHidden:NO];
                        self.ipField.text = self.device.ipAddress;
                        
                    }
                    
                    break;
                }
                case 3: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];
                        
                    } else {
                        [cell.contentView setHidden:NO];
                        self.portField.text = [self.device.port stringValue];

                    }

                    break;
                }
                case 4: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];
                        
                    } else {
                        [cell.contentView setHidden:NO];
                        self.ssidField.text = self.device.networkSSID;

                    }
                    
                    break;
                }
                case 5: {
                    if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                        [cell.contentView setHidden:YES];
                        
                    } else {
                        [cell.contentView setHidden:NO];
                        self.typeLabel.text = self.device.type;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    }
                    
                    // set the save button on the last table entry
                    if ([self.calledBy isEqualToString:@"Discovery"]) {
                        [self.saveButton setEnabled:YES];
                    } else {
//                        [self.saveButton setEnabled:NO];

                    }

                }
                    
                default:
                    break;
            }
            
        }
        case 1: {
            
            if (self.device == nil && ![self.calledBy isEqualToString:@"Discovery"]) {
                [cell.contentView setHidden:YES];
                
            } else {
                [cell.contentView setHidden:NO];
                               
            }

            
            
        }

    }
    return cell;
}

// launch view for selected cell - ipad
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
     
     switch (indexPath.section) {
        // nothing to do if a cell in the first section was selected
         case 0: {
             
             switch (indexPath.row) {
                 case 5:
                     self.showTypePicker = !self.showTypePicker;
                     // update tableview with these calls to animate the pickerview cell
                     [self.tableView beginUpdates];
                     [self.tableView endUpdates];
//                     [self.tableView reloadData];
                     break;
                     
                 default:
                     break;
             }
             break;
         }
                 
                     // this is where the links to next view controller live
         case 1: {
             
             if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

                 // save device info before we persent next view
                 [self updateDevice];

                 switch (indexPath.row) {
                         
                         // lauch security popover
                     case 0: {
                         
                         SecurityTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"SecurityTableViewController"];
                         [controller setSelectedDevice:self.device];

                         UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                         self.aPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                         [self.aPopoverController presentPopoverFromRect:cell.frame inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                         
                         break;
                         
                     }
                       
                         // launch relay popover
                     case 1: {
                         
                         RelayTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"RelayTableViewController"];
                         [controller setSelectedDevice:self.device];

                         UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                         self.aPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                         [self.aPopoverController presentPopoverFromRect:cell.frame inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                         
                         break;
                         
                     }
                         // launch inputs popover
                     case 2: {
                         
                         InputTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"InputTableViewController"];
                         [controller setSelectedDevice:self.device];
                         [controller setManagedObjectContext:self.managedObjectContext];

                         UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                         self.aPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                         [self.aPopoverController presentPopoverFromRect:cell.frame inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                         

                         break;
                         
                     }
                         // launch macros popover
                     case 3: {
                         
                         MacrosSettingsTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"MacrosSettingsTableViewController"];
                         [controller setSelectedDevice:self.device];

                         UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                         self.aPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
                         [self.aPopoverController presentPopoverFromRect:cell.frame inView:self.tableView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                         
                         
                         break;
                         
                     }

                         
                     default:
                         break;
                 }
             }
                 
             default:
                 break;
         }

     }
    
    
}

// this allows us to close any viewcontroller launched by segue or from didselectrow
- (IBAction)unwindFromSegue:(UIStoryboardSegue *) segue {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.aPopoverController dismissPopoverAnimated:YES];
        
        
    } else {
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    
}


// iphone navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // save device info before we persent next view
    [self updateDevice];
    
    // pass device along
    [[segue destinationViewController] setSelectedDevice:self.device];
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];

}

- (void)updateDevice {
    
    if ([self verifyInput]) {
        // build dictionary of info to create device
        NSDictionary *deviceInfo = @{@"name" : self.nameField.text ,
                                     @"macAddress" :[[CommonRoutines sharedInstance] unformatMacAddress:self.macField.text],
                                     @"ipAddress" : self.ipField.text,
                                     @"networkSSID" : self.ssidField.text,
                                     @"port" : self.portField.text,
                                     @"type" : self.typeLabel.text
                                     };
        
        // update core data
        self.device = [Device createDeviceFrom:deviceInfo InContext:self.managedObjectContext];
        
    }
}

- (BOOL)verifyInput {
    
    if ([self.nameField.text length] == 0) {
        // display alert - no device name
        NSDictionary *userInfo = @{@"title" : @"Device Name", @"error" : @"Please enter a device name."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    
    if ([self.macField.text length] == 0) {
        // display alert - no mac address
        NSDictionary *userInfo = @{@"title" : @"MAC Address", @"error" : @"Please enter a MAC Address."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    
        // verify format of mac address
        if ([self.macField.text length] == 17) {
            // display alert - no mac address
            
            NSArray *macArray = [self.macField.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
            if ([macArray count] == 6) {
                
                int macArrayLength = 0;
                for (int i = 0; i < [macArray count]; i++) {
                    NSString *tmp = macArray[i];
                    macArrayLength = macArrayLength + [tmp length];
                    
                }
                
                if (macArrayLength == 12) {
                    return YES;
                } else {
                    NSDictionary *userInfo = @{@"title" : @"MAC Address Format Error", @"error" : @"Please enter a MAC Address in 00:00:00:00:00:00 format."};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
     
                    return NO;

                    
                }
                
            } else {
                NSDictionary *userInfo = @{@"title" : @"MAC Address Format Error", @"error" : @"Please enter a MAC Address in 00:00:00:00:00:00 format."};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
                
                return NO;
                
            }
            
    
        } else {
            NSDictionary *userInfo = @{@"title" : @"MAC Address Format Error", @"error" : @"Please enter a MAC Address in 00:00:00:00:00:00 format."};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
            
            return NO;

            
        }
    
    if ([self.ipField.text length] == 0) {
        // display alert - no ip address
        NSDictionary *userInfo = @{@"title" : @"IP Address", @"error" : @"Please enter an IP Address."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    if ([self.ssidField.text length] == 0) {
        // display alert - no ssid
        NSDictionary *userInfo = @{@"title" : @"Network SSID", @"error" : @"Please enter a Network SSID."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    if ([self.portField.text length] == 0) {
        // display alert - no port
        NSDictionary *userInfo = @{@"title" : @"Port Number", @"error" : @"Please enter a port."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    if ([self.typeLabel.text length] == 0) {
        // display alert - no network connection type
        NSDictionary *userInfo = @{@"title" : @"Network Type", @"error" : @"Please enter a Network Type."};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
        
        return NO;
        
    }
    
    return YES;
}


@end
