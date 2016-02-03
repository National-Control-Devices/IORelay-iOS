//
//  MacroActionsTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroActionsTableViewController.h"
#import "MacroCommand.h"
#import "MacroActionConfigurationTableViewController.h"

@interface MacroActionsTableViewController ()

@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) NSString *macroName;
@property (nonatomic, strong) NSArray *macroTouchDownCommands;
@property (nonatomic, strong) NSArray *macroTouchUpCommands;

@end

@implementation MacroActionsTableViewController

- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
    }
    
}

- (void)setSelectedMacro:(Macro *)macro
{
    if (self.macro != macro) {
        self.macro = macro;
        
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // load the macro name
    self.macroName = self.macro.name;
    
    [self loadMacroCommands];
    [self initializeTableSections];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)loadMacroCommands {
    
    // get all commands for the current macro
    NSArray *commands = [[self.macro.commands allObjects] mutableCopy];
    
    // get the commands for Touch Down Event
    NSPredicate *tdPredicate = [NSPredicate predicateWithFormat:@"event == %@", @"TouchDown"];
    self.macroTouchDownCommands = [commands filteredArrayUsingPredicate:tdPredicate];
    
    self.macroTouchDownCommands = [self sortCommands:self.macroTouchDownCommands];

    // get the commands for Touch Up Event
    NSPredicate *tuPredicate = [NSPredicate predicateWithFormat:@"event == %@", @"TouchUp"];
    self.macroTouchUpCommands = [commands filteredArrayUsingPredicate:tuPredicate];
    
    self.macroTouchUpCommands = [self sortCommands:self.macroTouchUpCommands];


}


// sort inputs by number
- (NSArray *)sortCommands:(NSArray *)commands {
    
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    
    return [commands sortedArrayUsingDescriptors:sortDescriptors];
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textfield delegates
- (void)textFieldDidChange:(id)sender {
    
    UITextField *textField = sender;
    
    self.macroName = textField.text;

    
}


- (void)saveMacro {
    
    NSNumber *macroNumber;
    
    // we already have saved this macro so we're just updating
    if (self.macro.number != nil) {
        macroNumber = self.macro.number;
        
    // we are creating a new macro
    } else {
        // get next sequential number
        NSNumber *lastNumber = [Macro getLastMacroNumberInContext:self.device.managedObjectContext];
        int nextnumber = [lastNumber intValue] +1;
        macroNumber = [NSNumber numberWithInt:nextnumber];
        
    }
    
    // create dictionary
    if (self.macroName != nil) {
        NSDictionary *macroInfo = @{@"name" : self.macroName,
                                    @"number" : macroNumber
                                    };
        
        // update core data
        self.macro = [Macro createMacroFrom:macroInfo forDevice:self.device];
        
    }

    
    
}

// save macro info
- (IBAction)saveButtonPressed:(id)sender {
    
    if ([self verifyInput]) {
        [self saveMacro];
        
        [self performSegueWithIdentifier:@"saveSegue" sender:self];

    }
    
    

}

// user selected either add touchup or touchdown button
- (void)addCommand:(id)sender {
    
    if ([self verifyInput]) {
        // if we have entered or modified the macro name we need to save it before getting command
        if (![self.macroName isEqualToString:self.macro.name]) {
            [self saveMacro];

        }
        
        UIButton *button = sender;
        
        NSString *storyBoardName = @"Main";
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
            
        } else {
            storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
        MacroActionConfigurationTableViewController *actionsConfigViewController = [storyboard instantiateViewControllerWithIdentifier:@"MacroActionConfigurationTableViewController"];
        //    [actionsViewController setSelectedDevice:self.device];
        [actionsConfigViewController setSelectedMacro:self.macro];
        [actionsConfigViewController setSelectedMacroCommand:nil];
        
        if (button.tag == 1) {
            [actionsConfigViewController setEventType:@"TouchDown"];
        } else {
            [actionsConfigViewController setEventType:@"TouchUp"];
            
        }
        
        [self.navigationController pushViewController:actionsConfigViewController animated:YES];

    }
    
}

// edit input
- (BOOL)verifyInput {
    
    BOOL inputOK = YES;
    
    if ([self.macroName length] == 0) {
            // alert showing error
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Macro Name is Required" message:@"Please enter a Macro Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            inputOK = NO;
    }
    
    return inputOK;
}


- (UIButton *)createAddButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(addCommand:) forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:@"Add Command" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 7.0, 160.0, 30.0);
    
    return button;
}



- (void)initializeTableSections {
    
    // initialize arrays for uitableview
    self.tableSections = nil;
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *macroName = [[NSMutableArray alloc] init];
    NSMutableArray *touchDownCommands = [[NSMutableArray alloc] init];
    NSMutableArray *touchUpCommands = [[NSMutableArray alloc] init];
    
    // MACRO NAME SECTION
    // create name cell
    UITableViewCell *nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MacroActionCell"];

//    UITableViewCell *nameCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionCell"];
    
//    nameCell.textLabel.text = @"Name";
    
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(70, 7, 205, 30)];
    [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [nameField setBorderStyle:UITextBorderStyleRoundedRect];
    [nameField setPlaceholder:@"Enter Name"];
    [nameField setClearButtonMode:UITextFieldViewModeWhileEditing];
    nameField.delegate = self;
    nameField.tag = 1;
    nameField.text = self.macroName;
    
    [nameCell.contentView addSubview:nameField];

    [macroName addObject:nameCell];
    
    [self.tableSections addObject:macroName];
    
    // TOUCHDOWN COMMAND SECTION
    // create add cell
    UITableViewCell *touchDownCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MacroActionCell"];

//    UITableViewCell *touchDownCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionCell"];
    
//    touchDownCell.textLabel.text = @"Add New Command";
    UIButton *addTouchDownButton = [self createAddButton];
    addTouchDownButton.tag = 1;
    [touchDownCell addSubview:addTouchDownButton];
    
    
    [touchDownCommands addObject:touchDownCell];

    
    for (int i = 0; i < [self.macroTouchDownCommands count]; i++) {
        
        MacroCommand *macroCommand = [self.macroTouchDownCommands objectAtIndex:i];
        
        touchDownCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MacroActionCell"];
        touchDownCell.tag = 100 +i;

//        UITableViewCell *touchDownCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionCell"];
        
        touchDownCell.textLabel.text = macroCommand.commands;
        
        if ([macroCommand.delay intValue] > 0) {
            touchDownCell.detailTextLabel.text = [NSString stringWithFormat:@"with delay of %d milliseconds", [macroCommand.delay intValue]];

        }
        
        
        [touchDownCommands addObject:touchDownCell];
    }
    
    [self.tableSections addObject:touchDownCommands];
    
    // TOUCHUP COMMAND SECTION
    // create add cell
    UITableViewCell *touchUpCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MacroActionCell"];

//    UITableViewCell *touchUpCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionCell"];
    
    //    touchDownCell.textLabel.text = @"Add New Command";
    UIButton *addTouchUpButton = [self createAddButton];
    addTouchUpButton.tag = 2;
    [touchUpCell addSubview:addTouchUpButton];
    
    [touchUpCommands addObject:touchUpCell];
    
    
    for (int i = 0; i < [self.macroTouchUpCommands count]; i++) {
        
        MacroCommand *macroCommand = [self.macroTouchUpCommands objectAtIndex:i];
        
        touchUpCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MacroActionCell"];
        touchUpCell.tag = 200 +i;

//        UITableViewCell *touchUpCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionCell"];
        
        touchUpCell.textLabel.text = macroCommand.commands;
        
        if ([macroCommand.delay intValue] > 0) {
            touchUpCell.detailTextLabel.text = [NSString stringWithFormat:@"with delay of %d milliseconds", [macroCommand.delay intValue]];
            
        }

        
        [touchUpCommands addObject:touchUpCell];
    }
    
    [self.tableSections addObject:touchUpCommands];
    

    [self.tableView reloadData];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.tableSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *name;
   
    if (section == 0) {
        name = @"Macro Name";
    } else if (section == 1) {
        name = @"TouchDown Commands";
    } else if (section ==2) {
        name = @"TouchUp Commands";
    }
    return name;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.tableSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.tableSections)[indexPath.section][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    MacroCommand *command;
    // get command for this cell
    if (indexPath.section == 1) {
        command = [self.macroTouchDownCommands objectAtIndex:indexPath.row -1];
    } else if (indexPath.section == 2) {
        command = [self.macroTouchUpCommands objectAtIndex:indexPath.row -1];
    }
    
    
    NSString *storyBoardName = @"Main";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
        
    } else {
        storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    MacroActionConfigurationTableViewController *actionsConfigViewController = [storyboard instantiateViewControllerWithIdentifier:@"MacroActionConfigurationTableViewController"];
    [actionsConfigViewController setSelectedMacro:self.macro];
    [actionsConfigViewController setSelectedMacroCommand:command];
    
    [self.navigationController pushViewController:actionsConfigViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // allow deletion of command rows only
    if (indexPath.row > 0) {
        return YES;
    }
    
    return NO;
  
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            MacroCommand *command;
            // get command for this cell
            if (indexPath.section == 1) {
                command = [self.macroTouchDownCommands objectAtIndex:indexPath.row -1];
            } else if (indexPath.section == 2) {
                command = [self.macroTouchUpCommands objectAtIndex:indexPath.row -1];
            }
            
            [MacroCommand deleteMacroCommand:command inContext:self.macro.managedObjectContext];
            [self displayMacroUpdates];

            
        }

        
    }
    
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)unwindFromSegue:(UIStoryboardSegue *) segue {
    
    // close Configuration viewcontroller
    [self.navigationController popViewControllerAnimated:YES];
    
    // update tableview
    [self performSelectorOnMainThread:@selector(displayMacroUpdates) withObject:self waitUntilDone:NO];
    
    
}

- (void)displayMacroUpdates {
    
    [self loadMacroCommands];
    [self initializeTableSections];
    
}

@end
