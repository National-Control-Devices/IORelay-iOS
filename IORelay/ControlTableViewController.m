//
//  ControlTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/17/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "ControlTableViewController.h"
#import "RelayDelegate.h"
#import "InputDelegate.h"
#import "MacroDelegate.h"
#import "MBProgressHUD.h"


DisplayInfo currentType;

@interface ControlTableViewController ()

@property (nonatomic, strong) UISegmentedControl *deviceControlOptions;
@property (nonatomic, strong) NSMutableArray *tableSections;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation ControlTableViewController


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
    
    [self.navBar setTitle:self.device.name];
    
//    self.deviceControlOptions = nil;
    
//    self.deviceControlOptions = [[UISegmentedControl alloc] init];
//    [self.deviceControlOptions addTarget:self action:@selector(deviceControlOptionsDidChange:) forControlEvents: UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewNeedsUpdate:) name:@"TableViewNeedsUpdate" object:nil];

    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showControlActivityIndicator) name:@"ShowActivityIndicator" object:nil];
    
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideControlActivityIndicator) name:@"HideActivityIndicator" object:nil];
    


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        [self setControlType];

}

- (void)showControlActivityIndicator {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideControlActivityIndicator {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void)setControlType {
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        self.deviceControlOptions = nil;
    
        self.deviceControlOptions = [[UISegmentedControl alloc] init];
//        [self.deviceControlOptions addTarget:self action:@selector(deviceControlOptionsDidChange:) forControlEvents: UIControlEventValueChanged];

//    }
    // process Relay
    if ([self.device.displayRelays boolValue]) {
        // add relay as a selection in our segmentedcontrol
        [self.deviceControlOptions insertSegmentWithTitle:@"Relays" atIndex:self.deviceControlOptions.numberOfSegments animated:YES];
    }
    
    // process Inputs
    if ([self.device.displayInputs boolValue]) {
        [self.deviceControlOptions insertSegmentWithTitle:@"Inputs" atIndex:self.deviceControlOptions.numberOfSegments animated:YES];
    }
    
    // process Macros
    if ([self.device.displayMacros boolValue]) {
        [self.deviceControlOptions insertSegmentWithTitle:@"Macros" atIndex:self.deviceControlOptions.numberOfSegments animated:YES];
    }
    
    // load table and display
    if (self.deviceControlOptions.numberOfSegments > 0) {
        // default to the first segment for initial display
        self.deviceControlOptions.selectedSegmentIndex = 0;
        
        [self deviceControlOptionsDidChange:self.deviceControlOptions];
        
    }
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        [self.deviceControlOptions addTarget:self action:@selector(deviceControlOptionsDidChange:) forControlEvents: UIControlEventValueChanged];
        
//    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop the calls to update the input
    [self stopInputStatusUpdate];
    
    // disconnect any active tcp sockets
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisconnectTCPSockets" object:nil userInfo:nil];

    
}

- (void)setSelectedDevice:(Device *)device
{
    if (self.device != device) {
        self.device = device;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            [self setControlType];

        }

        
    }
    
}

- (void)deviceControlOptionsDidChange:(id)sender {
    
    UISegmentedControl *segmentedControl = sender;
    
    NSString *selectedSegment = [segmentedControl titleForSegmentAtIndex:segmentedControl.selectedSegmentIndex];
    
    if ([selectedSegment isEqualToString:@"Relays"]) {
        
        [self stopInputStatusUpdate];
        currentType = Relays;
        // we know we have relays so lets load the stati
        [[RelayDelegate sharedInstance] requestAllRelaysStatus];
    } else if ([selectedSegment isEqualToString:@"Inputs"]) {
        currentType = Inputs;
        // we know we have inputs so lets load their status now
        [self requestInputUpdate];

    } else if ([selectedSegment isEqualToString:@"Macros"]) {
        
        [self stopInputStatusUpdate];
        
        currentType = Macros;
        [self loadTableData];

    }
    
//    [self loadTableData];
}

- (void)stopInputStatusUpdate {
    
    if (self.inputTimer != nil && [self.inputTimer isValid]) {
        [self.inputTimer invalidate];
        self.inputTimer = nil;
    }

}

- (void)requestInputUpdate {
    
    
    [self stopInputStatusUpdate];
    
    self.inputTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateInputStatus) userInfo:nil repeats:YES];
    
    
}


- (void)updateInputStatus {
    
 //   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[InputDelegate sharedInstance] requestAllInputsStatus];
 
}

// Update the tableview
- (void)tableViewNeedsUpdate:(NSNotification *)notification {
    
//    [self hideControlActivityIndicator];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];

    // reload the table
    [self loadTableData];

}

- (void)loadTableData {
    
    // initialize data table
    self.tableSections = nil;
    
    switch (currentType) {
        case Relays:
            // load relay info
            self.tableSections = [[RelayDelegate sharedInstance] getRelayInfoForDevice:self.device];
            break;
            
        case Inputs:
            // load input info
             self.tableSections = [[InputDelegate sharedInstance] getInputInfoForDevice:self.device];
            break;
            
        case Macros:
            // load macro info
             self.tableSections = [[MacroDelegate sharedInstance] getMacroInfoForDevice:self.device];
            break;
            
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)relayButtonPressed:(id)sender {
    NSLog(@"Relay button pressed");
    
    UIButton *button = (UIButton *)sender;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowActivityIndicator" object:nil userInfo:nil];
    
    [[RelayDelegate sharedInstance] toggleRelay:[NSNumber numberWithInt:button.tag]];
    
}

- (void)momentaryRelayButtonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    [[RelayDelegate sharedInstance] toggleMomentaryRelay:[NSNumber numberWithInt:button.tag] withAction:@"Pressed"];
    
}


- (void)momentaryRelayButtonReleased:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    [[RelayDelegate sharedInstance] toggleMomentaryRelay:[NSNumber numberWithInt:button.tag] withAction:@"Released"];
    
}

// macro command events
- (void)macroTouchDownEvent:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    [[MacroDelegate sharedInstance] performTouchDownCommandsForMacro:[NSNumber numberWithInt:button.tag]];
    
}

- (void)macroTouchUpEvent:(id)sender {

    [[MacroDelegate sharedInstance] performTouchUpCommandsForMacro];
    
}




- (void)createContraintsForSegmentedControlInHeaderView:(UIView *)headerView {   //WithFrame:CGRectMake(55, 7, 205, 30)];
    
    // add to cell now so restraints will work
    [headerView addSubview:self.deviceControlOptions];
    
    // autolayout restraint to use the entire cell width
    // use only restraints specified here
    self.deviceControlOptions.translatesAutoresizingMaskIntoConstraints = NO;
    // restraint for height
    NSLayoutConstraint *controlHeight = [NSLayoutConstraint constraintWithItem:self.deviceControlOptions
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:30];
    [self.deviceControlOptions addConstraint:controlHeight];
    
    // restraint for right padding
    NSLayoutConstraint *controlWidth = [NSLayoutConstraint constraintWithItem:self.deviceControlOptions
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0
                                                                     constant:205];
    
    [self.deviceControlOptions addConstraint:controlWidth];
    

    // restraint from bottom of headerview
    NSLayoutConstraint *controlBottom = [NSLayoutConstraint constraintWithItem:self.deviceControlOptions
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:headerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:-5];
    
    
    
    [headerView addConstraint:controlBottom];
    
    
    // restraint for centering
    NSLayoutConstraint *controlX = [NSLayoutConstraint constraintWithItem:self.deviceControlOptions
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:headerView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0];
    
    [headerView addConstraint:controlX];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    
    if (section == 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 7,tableView.bounds.size.width, 30)];
        [headerView setBackgroundColor:[UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f]];
        
        [self createContraintsForSegmentedControlInHeaderView:headerView];
//        self.deviceControlOptions.center = headerView.center;
        
        [headerView addSubview:self.deviceControlOptions];
        return headerView;
    } else {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
//    return 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [[self.tableSections objectAtIndex:section] count];
        
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.tableSections)[indexPath.section][indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
