//
//  InputTypeTableViewController.m
//  IORelay
//
//  Created by John Radcliffe on 9/24/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputTypeTableViewController.h"

@interface InputTypeTableViewController ()

@property (nonatomic, strong) NSMutableArray *inputKeywords;
@property (nonatomic, strong) UITableViewCell *currentCell;

@end

@implementation InputTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputKeywords = [[InputTypeKeywords getTypeKeywordsInContext:self.input.managedObjectContext] mutableCopy];
    
    if ([self.inputKeywords count] == 0) {
        [InputTypeKeywords createInitialInputKeywordsInContext:self.input.managedObjectContext];
        self.inputKeywords = [[InputTypeKeywords getTypeKeywordsInContext:self.input.managedObjectContext] mutableCopy];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.inputKeywords count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InputTypeKeyword" forIndexPath:indexPath];
    
    // Configure the cell...
    
    InputTypeKeywords *keyword = [self.inputKeywords objectAtIndex:indexPath.row];
    
    cell.textLabel.text = keyword.name;
    if ([keyword.name isEqualToString:self.input.type]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentCell = cell;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // unselect current cell
    self.currentCell.accessoryType = UITableViewCellAccessoryNone;
    
    // mark the current selected cell
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // save current cell
    self.currentCell = selectedCell;
    
    self.input.type = self.currentCell.textLabel.text;
    self.input.typeNumber = [NSNumber numberWithInt:indexPath.row];
    
    // save input type
    [Input updateInput:self.input];

    
    [self performSegueWithIdentifier:@"saveSegue" sender:self];

    
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
