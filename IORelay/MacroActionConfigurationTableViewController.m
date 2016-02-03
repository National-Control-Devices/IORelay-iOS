//
//  MacroActionConfigurationTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroActionConfigurationTableViewController.h"

@interface MacroActionConfigurationTableViewController ()

@property (nonatomic, strong) NSMutableArray *tableSections;

@property (nonatomic, strong) NSString *delay;
@property (nonatomic, strong) NSString *commands;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation MacroActionConfigurationTableViewController

- (void)setSelectedMacro:(Macro *)macro
{
    if (self.macro != macro) {
        self.macro = macro;
        
    }
    
}

- (void)setSelectedMacroCommand:(MacroCommand *)command
{
    if (self.macroCommand != command) {
        self.macroCommand = command;
        
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.navigationController setTitle:@"Action Configuration"];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navBar setTitle:self.macro.name];
    
    // load initial settings if we have selected command for editing
    if (self.macroCommand != nil) {
       
        // recommended delay of 50 milliseconds
        self.delay = [self.macroCommand.delay stringValue] != nil? [self.macroCommand.delay stringValue] : @"50";
        self.commands = self.macroCommand.commands;
        self.eventType = self.macroCommand.event;
        
    } else {
        self.delay = @"50";

    }
    
    [self initializeTableSections];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textfield delegates
- (void)textFieldDidChange:(id)sender {
    
    UITextField *textField = sender;
    
    switch (textField.tag) {
        case 1:
            self.commands = textField.text;
            break;
            
        case 2:
            self.delay = textField.text;
            break;

            
        default:
            break;
    }
    
    
}

- (void)saveCommand {
    
    NSNumber *commandNumber;
    
    // we already have saved this macro so we're just updating
    if (self.macroCommand.number != nil) {
        commandNumber = self.macroCommand.number;
        
        // we are creating a new macro
    } else {
        // get next sequential number
        NSNumber *lastNumber = [MacroCommand getLastCommandNumberForMacro:self.macro InContext:self.macro.managedObjectContext];
        int nextnumber = [lastNumber intValue] +1;
        commandNumber = [NSNumber numberWithInt:nextnumber];
        
    }
    
    // create dictionary
    NSDictionary *commandInfo = @{
                                  @"delay" : self.delay == nil? @"0" : self.delay,
                                  @"commands" : self.commands,
                                  @"type" : self.eventType,
                                  @"number" : commandNumber
                                  };
    
    // update core data
    [MacroCommand createMacroCommandFrom:commandInfo forMacro:self.macro];
    
    
   
}

// edit input
- (BOOL)verifyInput {
    
    BOOL inputOK = YES;
    
    if ([self.commands length] == 0) {
        // alert showing error
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Commands are Required" message:@"Please enter a command" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        inputOK = NO;
    }
    
    return inputOK;
}




- (IBAction)saveButtonPressed:(id)sender {
    
    if ([self verifyInput]) {

        // get next number for command
        
        [self saveCommand];
        
        [self performSegueWithIdentifier:@"saveSegue" sender:self];
        

    }
    
   
}


- (void)initializeTableSections {
    
    // initialize arrays for uitableview
    self.tableSections = nil;
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *macroActionConfig = [[NSMutableArray alloc] init];
    
    // create delimiter cell
    UITableViewCell *delimiterCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionConfigCell"];
    
    delimiterCell.textLabel.text = @"Use a , to separate command bytes";
        
    [macroActionConfig addObject:delimiterCell];
    
    // add command cell
    UITableViewCell *commandCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionConfigCell"];
    
    commandCell.textLabel.text = @"Commands";
    
    UITextField *commandField = [[UITextField alloc] initWithFrame:CGRectMake(110, 7, 190, 30)];
    [commandField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [commandField setBorderStyle:UITextBorderStyleRoundedRect];
    [commandField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [commandField setPlaceholder:@"Enter Commands"];
    commandField.delegate = self;
    commandField.tag = 1;
    commandField.text = self.commands;
    [commandCell.contentView addSubview:commandField];
    
    [macroActionConfig addObject:commandCell];
    

    
    // add delay cell
    UITableViewCell *delayCell = [self.tableView dequeueReusableCellWithIdentifier:@"MacroActionConfigCell"];
    
    delayCell.textLabel.text = @"Delay in milliseconds";
    
    UITextField *delayField = [[UITextField alloc] initWithFrame:CGRectMake(225, 7, 75, 30)];
    [delayField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [delayField setBorderStyle:UITextBorderStyleRoundedRect];
    [delayField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
    [delayField setPlaceholder:@"Enter Delay"];
    delayField.delegate = self;
    delayField.tag = 2;
    delayField.text = self.delay;
    
    [delayCell.contentView addSubview:delayField];
    [macroActionConfig addObject:delayCell];

    
    [self.tableSections addObject:macroActionConfig];
    
    [self.tableView reloadData];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.tableSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.eventType;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.tableSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.tableSections)[indexPath.section][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
