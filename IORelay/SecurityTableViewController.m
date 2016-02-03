//
//  SecurityTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "SecurityTableViewController.h"


@interface SecurityTableViewController ()

@end

@implementation SecurityTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set UITextField delegates
    self.accessPinField.delegate = self;
    self.accessPinField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.configurationPinField.delegate = self;
    self.configurationPinField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    // set initial value for switches
    if ([self.device.accessSwitch boolValue]) {
        [self.accessSwitch setOn:YES];
    } else {
        [self.accessSwitch setOn:NO];
    }
    
    self.accessPinField.text = self.device.accessPin;
    
    if ([self.device.configSwitch boolValue]) {
        [self.configurationSwitch setOn:YES];
    } else {
        [self.configurationSwitch setOn:NO];
    }
    
    self.configurationPinField.text = self.device.configPin;
    
//    // disable save button until something is updated
//    [self.saveButton setEnabled:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// initialization code to save current device
- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
      
    }
    
}

#pragma mark - textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
//    [self.saveButton setEnabled:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}


- (IBAction)accessSwitchPressed:(id)sender {
    
    if (self.accessSwitch.isOn) {
        self.accessPinCell.hidden = NO;
    } else {
        self.accessPinCell.hidden = YES;
        self.accessPinField.text = nil;
    }

    [self.tableView reloadData];
}

- (IBAction)configurationSwitchPressed:(id)sender {
    
    if (self.configurationSwitch.isOn) {
        self.configurationPinCell.hidden = NO;
    } else {
        self.configurationPinCell.hidden = YES;
        self.configurationPinField.text = nil;
    }
    
    [self.tableView reloadData];

}

- (IBAction)saveButtonPressed:(id)sender {
    
    // edit input
    if ([self verifyInput]) {
        
        NSDictionary *securityInfo = @{@"accessSwitch" : [NSNumber numberWithBool:self.accessSwitch.isOn] ,
                                       @"accessPin" : self.accessPinField.text,
                                       @"configSwitch" : [NSNumber numberWithBool:self.configurationSwitch.isOn],
                                       @"configPin" : self.configurationPinField.text
                                       };
        
        // update core data
        [Device updateSecuritySettings:securityInfo forDevice:self.device];
        
        // if access is locked set unlocked value to no - so the user will have to enter the pin
        if (self.accessSwitch.isOn) {
            [Device accessUnlocked:self.device unlocked:[NSNumber numberWithBool:NO]];
            
        }
        
        // if configuration is locked set unlocked value to no - so the user will have to enter the pin
        if  (self.configurationSwitch.isOn) {
            [Device configurationUnlocked:self.device unlocked:[NSNumber numberWithBool:NO]];
            
        }
        
        
        [self performSegueWithIdentifier:@"saveSegue" sender:self];

    }
    
   
}

// edit input
- (BOOL)verifyInput {
    
    BOOL inputOK = YES;
    
    if (self.accessSwitch.isOn) {
        if ([self.accessPinField.text length] == 0) {
            // alert showing error
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access Pin is Required" message:@"Please enter a valid pin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

            inputOK = NO;
        }
    }
    
    if (self.configurationSwitch.isOn) {
        if ([self.configurationPinField.text length] == 0) {
            // alert showing error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configuration Pin is Required" message:@"Please enter a valid pin" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

            inputOK = NO;
        }
    }
    
    return inputOK;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0) {
        if (self.accessSwitch.isOn) {
            return 2;
        }
        
    } else {
       
        if (self.configurationSwitch.isOn) {
            return 2;
        }

        
    }


    return 1;
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//   UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//   return cell;
//}
//

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
