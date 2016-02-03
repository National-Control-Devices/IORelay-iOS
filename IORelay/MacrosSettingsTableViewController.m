//
//  MacrosSettingsTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/18/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacrosSettingsTableViewController.h"
#import "Macro+Access.h"
#import "MacroActionsTableViewController.h"

@interface MacrosSettingsTableViewController ()

@property (nonatomic, strong) NSMutableArray *tableSections;
@property (strong, nonatomic) NSMutableArray *macros;
@property (strong, nonatomic) Macro *macro;

@property (nonatomic, strong) UISwitch *displayMacroSwitch;




@end

@implementation MacrosSettingsTableViewController

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
    
    // initialize display input switch
    self.displayMacroSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(263, 6, 51, 31)];
    [self.displayMacroSwitch addTarget:self action:@selector(displaySwitchPressed:) forControlEvents:UIControlEventValueChanged];
    
    [self.displayMacroSwitch setOn:[self.device.displayMacros boolValue]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadMacros];
    [self initializeTableSections];
}

- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
    }
    
}

- (void)loadMacros {
    
    // get all inputs for the current device
    self.macros = [[self.device.macros allObjects] mutableCopy];
    [self sortMacros];
    
    
}


// sort inputs by number
- (void)sortMacros {
    
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:nameSortDescriptor];
    NSArray *tempSortArray = [NSArray arrayWithArray:self.macros];
    
    self.macros = [[tempSortArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
}



- (void)displaySwitchPressed:(id)sender {
    
    
    // if we want to display the inputs
    if (self.displayMacroSwitch.isOn) {
        
        // set display device to yes in device
        [Device displayMacrosFor:self.device display:[NSNumber numberWithBool:YES]];
      
        
    } else {
        
        [Device displayMacrosFor:self.device display:[NSNumber numberWithBool:NO]];
        
    }
    
    
    [self initializeTableSections];

}

- (void)initializeTableSections {
    
    // initialize arrays for uitableview
    self.tableSections = nil;
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    if (self.displayMacroSwitch.isOn) {
        
        // create table entries for all relays
        for (int i = 0; i < [self.macros count]; i++) {
            
            Macro *macro = [self.macros objectAtIndex:i];
            
            // create name cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MacroCell"];
            cell.tag = i+1;
            
            cell.textLabel.text = macro.name;
            
            
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
    headerLabel.text = @"Display Macros";
    [headerView addSubview:headerLabel];
    
    [headerView addSubview:self.displayMacroSwitch];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 44.f;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.tableSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.tableSections)[indexPath.section][indexPath.row];
}

// user has selected an existing macro
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    int macroIndex = (int)cell.tag -1;
    
    if (macroIndex >= 0) {
        Macro *macro = [self.macros objectAtIndex:macroIndex];
        
        NSString *storyBoardName = @"Main";
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
            
        } else {
            storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        MacroActionsTableViewController *actionsViewController = [storyboard instantiateViewControllerWithIdentifier:@"MacroActionsTableViewController"];
        [actionsViewController setSelectedDevice:self.device];
        [actionsViewController setSelectedMacro:macro];
        
        [self.navigationController pushViewController:actionsViewController animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
        // Delete the row from the data source
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        int macroIndex = (int)cell.tag -1;
        
        if (macroIndex >= 0) {
            Macro *macro = [self.macros objectAtIndex:macroIndex];
            
            [Macro deleteMacro:macro inContext:self.device.managedObjectContext];
            
            [self displayMacroUpdates];
        }

    }

}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}



#pragma mark - Navigation
// this allows us to close any viewcontroller launched by segue or from didselectrow
- (IBAction)unwindFromSegue:(UIStoryboardSegue *) segue {
    
    // close Action viewcontroller
    [self.navigationController popViewControllerAnimated:YES];

    // update tableview 
    [self performSelectorOnMainThread:@selector(displayMacroUpdates) withObject:self waitUntilDone:NO];

    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MacroActionsTableViewController *actionsViewController = [segue destinationViewController];
    [actionsViewController setSelectedDevice:self.device];

    
}


- (void)displayMacroUpdates {
    
    [self loadMacros];
    [self initializeTableSections];
    
}



@end
