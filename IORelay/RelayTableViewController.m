//
//  RelayTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "RelayTableViewController.h"
#import "Relay+Access.h"

@interface RelayTableViewController ()

@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) NSArray *numberOfRelays;
@property (strong, nonatomic) NSMutableArray *relays;

@property (nonatomic, strong) NSMutableDictionary *nameDict;
@property (nonatomic, strong) NSMutableDictionary *momentaryDict;
@property (nonatomic) NSInteger numberOfRelaysIndex;

@property (nonatomic, strong) UISwitch *displayRelaySwitch;
@property (nonatomic, strong) UIStepper *numberStepper;



@end

@implementation RelayTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.numberOfRelays = @[@"1",@"2",@"4",@"8",@"16",@"24",@"32"];
    
    // initialize display relay switch
    self.displayRelaySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(263, 6, 51, 31)];
    [self.displayRelaySwitch addTarget:self action:@selector(displaySwitchPressed:) forControlEvents:UIControlEventValueChanged];

    [self.displayRelaySwitch setOn:[self.device.displayRelays boolValue]];
    
    // initialize stepper to increment/decrement number of relays to display
    self.numberStepper = [[UIStepper alloc] initWithFrame:CGRectMake(218, 51, 94, 30)];
    [self.numberStepper addTarget:self action:@selector(numberOfRelaysStepperPressed:) forControlEvents:UIControlEventValueChanged];
    
    self.numberStepper.value = self.numberOfRelaysIndex;


}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.nameDict = [[NSMutableDictionary alloc] initWithCapacity:[self.device.numberOfRelays intValue]];
    self.momentaryDict = [[NSMutableDictionary alloc] initWithCapacity:[self.device.numberOfRelays intValue]];
    
    
    [self checkNumberOfRelays];

    
    [self initializeTableSections];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
    }
    
}

- (void)loadRelays {
    
    // get all inputs for the current device
    self.relays = [[self.device.relays allObjects] mutableCopy];
    [self sortRelays];
    
    // save off initial values
    // load the names dictionary with the initial values so we can check to see what gets updated
    for (int i = 0; i < [self.relays count]; i++) {
        Relay *relay = [self.relays objectAtIndex:i];
        
        NSString *key = [[NSNumber numberWithInt:[relay.number intValue]] stringValue];
        
        // load off name
        [self.nameDict addEntriesFromDictionary:@{key : relay.name != nil? relay.name : @""}];
        
        // load momentary dictionary with initial values
        [self.momentaryDict addEntriesFromDictionary:@{key : relay.momentary}];
        
    }
    
}


// sort inputs by number
- (void)sortRelays {
    
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    NSArray *tempSortArray = [NSArray arrayWithArray:self.relays];
    
    self.relays = [[tempSortArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
}

- (IBAction)saveButtonPressed:(id)sender {
    
    // save inputs back to core data
    
    for (int i = 0 ; i < [self.relays count]; i++) {
        
        Relay *relay = [self.relays objectAtIndex:i];
        NSString *key = [[NSNumber numberWithInt:i+1] stringValue];
        
        if (![relay.name isEqualToString:[self.nameDict valueForKey:key]]) {
            [Relay updateRelay:relay];
            
        } else {
            
            NSNumber *momentarySwitch = (NSNumber *)[self.momentaryDict valueForKey:key];
            
            if ([relay.momentary boolValue] != [momentarySwitch boolValue] ) {
                [Relay updateRelay:relay];
            }
            
            
        }


    }
    
    
    [self performSegueWithIdentifier:@"saveSegue" sender:self];
    

}

- (void)numberOfRelaysStepperPressed:(id)sender {
    
    self.numberStepper = sender;
    
    int stepperCount = self.numberStepper.value;
    
     // only alow stepper to operate within our array of # of relays - self.numberOfRelays = @[@"1",@"2",@"4",@"8",@"16",@"24",@"32"];
    if (stepperCount < 0) {
        self.numberStepper.value = 0;
        stepperCount = 0;
    }
    
    if (stepperCount > 6) {
        self.numberStepper.value = 6;
        stepperCount = 6;
    }
    
    [Device updateNumberOfRelaysFor:self.device number:[NSNumber numberWithInteger:[[self.numberOfRelays objectAtIndex:stepperCount] integerValue]]];
        
    [self checkNumberOfRelays];


    
    
}

- (void)displaySwitchPressed:(id)sender {
    
    // if we want to display the inputs
    if (self.displayRelaySwitch.isOn) {
        
        // set display device to yes in device
        [Device displayRelaysFor:self.device display:[NSNumber numberWithBool:YES]];
        
    } else {
        
        [Device displayRelaysFor:self.device display:[NSNumber numberWithBool:NO]];
        
    }
    

    [self initializeTableSections];

}

- (void)momentarySwitchPressed:(id)sender {
    
    
    UISwitch *momentarySwitch = sender;
    
    // get the relay that was updated
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"number == %d", momentarySwitch.tag];
    NSArray *filteredArray = [self.relays filteredArrayUsingPredicate:predicate];
    Relay *updatedRelay = [filteredArray lastObject];

    // if we want to display the inputs
    if (momentarySwitch.isOn) {
        updatedRelay.momentary = [NSNumber numberWithBool:YES];
        
    } else {
        
        updatedRelay.momentary = [NSNumber numberWithBool:NO];

    }
    
    // replace the relay from the array
    [self.relays replaceObjectAtIndex:(momentarySwitch.tag -1) withObject:updatedRelay];

    
    [self initializeTableSections];

    
}

- (void)checkNumberOfRelays {
    
//    // get current relays
   [self loadRelays];
    
    // see if we need to add or delete relays
    if ([self.relays count] < [self.device.numberOfRelays intValue]) {
        // add relays
        [self createRelays];
        [self loadRelays];
        
    } else if ([self.relays count] > [self.device.numberOfRelays intValue]) {
        // delete relays
        [self deleteRelays];
        [self loadRelays];
    }
    
    [self initializeTableSections];

}

- (void)createRelays {
    
    // get the last object so we can get the highest number relay
//    Relay *relay = [self.relays lastObject];
    
    for (int i = (int)[self.relays count]; i < [self.device.numberOfRelays intValue]; i++) {
        
        [Relay createRelayNumber:[NSNumber numberWithInt:(i +1)] ForDevice:self.device];
    }
    

}


- (void)deleteRelays {
    
    
    for (int i = (int)[self.relays count]; i > [self.device.numberOfRelays intValue]; i--) {
        
        // get the last object so we can get the highest number relay
        Relay *relay = [self.relays lastObject];
        
        // if the relay number is greater than the number we are supposed to have - delete it!
        if ([relay.number intValue] > [self.device.numberOfRelays intValue]) {
            
            // remove relay from arrary
            [self.relays removeObject:relay];
            
            // delete from core data
            [Relay deleteRelay:relay];
            
        }

    }

    
}


#pragma mark - textfield delegates
- (void)textFieldDidChange:(id)sender {
    
    UITextField *textField = sender;
    
    [self saveUpdatedName:textField.text forRelay:textField.tag];
    
}


- (void)saveUpdatedName:(NSString *)name forRelay:(NSInteger)relayNumber {
    
    int relayIndex = (int)relayNumber -1;
    
    Relay *updatedRelay = [self.relays objectAtIndex:relayIndex];
    
    updatedRelay.name = name;
    
    // replace the input from the array
    [self.relays replaceObjectAtIndex:relayIndex withObject:updatedRelay];
    
}


- (void)initializeTableSections {
    
    // initialize arrays for uitableview
    self.tableSections = nil;
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    if (self.displayRelaySwitch.isOn) {
        
        // create table entries for all relays
        for (int i = 0; i < [self.relays count]; i++) {
            
            Relay *relay = [self.relays objectAtIndex:i];
            
            // create name cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RelayCell"];
            
            cell.textLabel.text = [NSString stringWithFormat:@"Relay %d",i +1];
            
            UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(95, 7, 205, 30)];
            [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [nameField setBorderStyle:UITextBorderStyleRoundedRect];
            [nameField setPlaceholder:@"Enter Name"];
            [nameField setClearButtonMode:UITextFieldViewModeWhileEditing];
            nameField.delegate = self;
            nameField.tag = i+1;
            nameField.text = relay.name;
            
            [cell.contentView addSubview:nameField];
            
            [list addObject:cell];
            
            // create momentary cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RelayCell"];
            
            cell.textLabel.text = @"Momentary";
            
            UISwitch *momentarySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(263, 6, 51, 31)];
            [momentarySwitch addTarget:self action:@selector(momentarySwitchPressed:) forControlEvents:UIControlEventValueChanged];
            momentarySwitch.tag = i+1;
            [momentarySwitch setOn:[relay.momentary boolValue]];
            
            [cell.contentView addSubview:momentarySwitch];
            
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
        headerLabel.text = @"Display Relays";
        [headerView addSubview:headerLabel];
        
        //        [headerView setBackgroundColor:[UIColor lightGrayColor]];
        [headerView addSubview:self.displayRelaySwitch];
    
    if (self.displayRelaySwitch.isOn) {
        UILabel *numberOfRelaysLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 51, 100, 30)];
        numberOfRelaysLabel.text = @"# of Relays";
        [headerView addSubview:numberOfRelaysLabel];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 51, 50, 30)];
        numberLabel.text = [self.device.numberOfRelays stringValue];
        
        [headerView addSubview:numberLabel];
        
        // set index to number of relays
        self.numberOfRelaysIndex = [self.numberOfRelays indexOfObject:numberLabel.text];
        UIStepper *numberStepper = [[UIStepper alloc] initWithFrame:CGRectMake(218, 51, 94, 30)];
        [numberStepper addTarget:self action:@selector(numberOfRelaysStepperPressed:) forControlEvents:UIControlEventValueChanged];

        numberStepper.value = self.numberOfRelaysIndex;
        
        [headerView addSubview:numberStepper];

        
    }
        
        
        
//        UISwitch *displaySwitch = (UISwitch *)[displayCell viewWithTag:1];
//        
//        [displaySwitch setOn:[self.device.displayRelays boolValue]];
        

        return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (self.displayRelaySwitch.isOn) {
        return 88.f;
    } else {
        return 44.f;

    }
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

- (void)displayRelayUpdates {
    
    [self checkNumberOfRelays];
    [self initializeTableSections];
    
}


@end
