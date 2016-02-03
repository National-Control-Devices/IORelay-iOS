//
//  InputTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputTableViewController.h"
#import "InputTypeTableViewController.h"

@interface InputTableViewController ()

@property (strong, nonatomic) NSMutableArray *inputs;

@property (nonatomic, strong) NSMutableDictionary *nameDict;
@property (nonatomic, strong) NSMutableDictionary *typeDict;

@property (nonatomic, strong) NSMutableArray *tableSections;

@property (nonatomic, strong) UISwitch *displayInputSwitch;


@end

@implementation InputTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // initialize display input switch
    self.displayInputSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(263, 6, 51, 31)];
    [self.displayInputSwitch addTarget:self action:@selector(displaySwitchPressed:) forControlEvents:UIControlEventValueChanged];
    
    [self.displayInputSwitch setOn:[self.device.displayInputs boolValue]];

    
}
//
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.nameDict = [[NSMutableDictionary alloc] initWithCapacity:8];
    self.typeDict = [[NSMutableDictionary alloc] initWithCapacity:8];

    [self loadInputs];

    [self initializeTableSections];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadInputs {
    
    self.inputs = nil;
    
    // get all inputs for the current device
    self.inputs = [[self.device.inputs allObjects] mutableCopy];
    [self sortInputs];
    
    // save off initial values
    // load the names dictionary with the initial values so we can check to see what gets updated
    for (int i = 0; i < [self.inputs count]; i++) {
        Input *input = [self.inputs objectAtIndex:i];
        
        NSString *key = [[NSNumber numberWithInt:[input.number intValue]] stringValue];

        
        [self.nameDict addEntriesFromDictionary:@{key : input.name != nil? input.name : @""}];
        
        // load types dictionary with initial values
        
        [self.typeDict addEntriesFromDictionary:@{key : input.type != nil? input.type : @"" }];
        
    }

}

// ui interaction
- (IBAction)saveButtonPressed:(id)sender {
    
    // save inputs back to core data
    
    for (int i = 0 ; i < [self.inputs count]; i++) {
        
        Input *input = [self.inputs objectAtIndex:i];
        NSString *key = [[NSNumber numberWithInt:i+1] stringValue];
        
        if (![input.name isEqualToString:[self.nameDict valueForKey:key]] && [input.type isEqualToString:[self.typeDict valueForKey:key]]) {
                        
            [Input updateInput:input];
        
        }        

    }
    
    [self performSegueWithIdentifier:@"saveSegue" sender:self];

}
- (void)displaySwitchPressed:(id)sender {
    

    // if we want to display the inputs
    if (self.displayInputSwitch.isOn) {
        
        // set display device to yes in device
        [Device displayInputsFor:self.device display:[NSNumber numberWithBool:YES]];
        
        // create the input records if they do not exist
        if ([self.device.inputs count] == 0) {
            [self createInputs];
        }
        
        // get the inputs and update tableview
        [self displayInputUpdates];
        
        
    } else {
        
        [Device displayInputsFor:self.device display:[NSNumber numberWithBool:NO]];
//        self.inputs = nil;
//        self.tableSections = nil;
        [self initializeTableSections];
        
    }
    
  
    
   
}


- (void)createInputs {
    
    // create 8 default inputs
    
    for (int i =1; i < 9; i++) {
        
        [Input createInputNumber:[NSNumber numberWithInt:i] ForDevice:self.device];
    }
    
    [self loadInputs];
    
}


// sort inputs by number
- (void)sortInputs {
    
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    NSArray *tempSortArray = [NSArray arrayWithArray:self.inputs];
    
    self.inputs = [[tempSortArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
}

#pragma mark - textfield delegates
//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    
//}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//}

// PHONE NUMBER FORMATTER
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self saveUpdatedName:textField.text forInput:textField.tag];
    
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    
    UITextField *textField = sender;
    
    [self saveUpdatedName:textField.text forInput:textField.tag];
    
}


- (void)saveUpdatedName:(NSString *)name forInput:(NSInteger)inputNumber {
    
    int inputIndex = (int)inputNumber -1;
    
    Input *updatedInput = [self.inputs objectAtIndex:inputIndex];
    
    updatedInput.name = name;
    
    // replace the input from the array
    [self.inputs replaceObjectAtIndex:inputIndex withObject:updatedInput];
    
}

- (void)initializeTableSections {
    
    // initialize arrays for uitableview
    self.tableSections = nil;
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    if (self.displayInputSwitch.isOn) {
        // create table entries for all inputs
        for (int i = 0; i < [self.inputs count]; i++) {
            
             Input *input = [self.inputs objectAtIndex:i];
            
            // create name cell
//            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InputCell"];
            
//            if (cell == nil) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InputCell"];
                
//            } else {
//                cell.textLabel.text = nil;
//                [[cell.contentView viewWithTag:i+1]removeFromSuperview];
//            }

            cell.accessoryType = UITableViewCellAccessoryNone;
//            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
//            nameLabel.text = [NSString stringWithFormat:@"Input %d",i +1];
//            [cell.contentView addSubview:nameLabel];
            
            cell.textLabel.text = [NSString stringWithFormat:@"Input %d",i +1];
            
            UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(95, 7, 205, 30)];
            [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [nameField setBorderStyle:UITextBorderStyleRoundedRect];
            [nameField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [nameField setPlaceholder:@"Enter Name"];
            nameField.delegate = self;
            nameField.tag = i+1;
            nameField.text = input.name;
            
            [cell.contentView addSubview:nameField];
            
            [list addObject:cell];
            
            
            // create type cell
          

            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InputCell"];
            cell.tag = i+1;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textLabel.text = @"Type";
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 7, 205, 30)];
            
            typeLabel.text = input.type;
            typeLabel.enabled = NO;
            
            [cell.contentView addSubview:typeLabel];
            
           [list addObject:cell];

            
            
        }

    }
    
    
    [self.tableSections addObject:list];
    [self.tableView reloadData];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.tableSections count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *headerView = [[UIView alloc] init]; //WithFrame:CGRectMake(0, 0,tableView.bounds.size.width, 60)];
    [headerView setBackgroundColor:[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f]];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 150, 30)];
    headerLabel.text = @"Display Inputs";
    [headerView addSubview:headerLabel];
    
    //        [headerView setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:self.displayInputSwitch];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 44.f;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
     return [[self.tableSections objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     return (self.tableSections)[indexPath.section][indexPath.row];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // is row is odd then we have pressed the type row
    if (indexPath.row % 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
        int inputIndex = (int)cell.tag -1;
        
        Input *input = [self.inputs objectAtIndex:inputIndex];
        
        NSString *storyBoardName = @"Main";
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
            
        } else {
            storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        InputTypeTableViewController *inputTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"InputTypeTableViewController"];
        inputTypeViewController.input = input;
        
        [self.navigationController pushViewController:inputTypeViewController animated:YES];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


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
    

    
}
*/

// close inputtypeviewcontroller
- (IBAction)unwindFromSegue:(UIStoryboardSegue *) segue {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    // update tableview
    [self performSelectorOnMainThread:@selector(displayInputUpdates) withObject:self waitUntilDone:NO];

}


- (void)displayInputUpdates {
    
    [self loadInputs];
    [self initializeTableSections];
    
}




@end
