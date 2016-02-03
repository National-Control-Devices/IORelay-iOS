//
//  MacroDelegate.m
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroDelegate.h"
#import "Macro.h"
#import "MacroControl.h"

static MacroDelegate *_sharedInstance;

@implementation MacroDelegate

# pragma mark - Object Lifecycle
+ (MacroDelegate *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MacroDelegate alloc] init];
        
    });
    
    return _sharedInstance;
}


- (id)init {
    
    self = [super init];
    
    NSString *storyBoardName = @"Main";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
        
    } else {
        storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    self.parentViewController = [storyboard instantiateViewControllerWithIdentifier:@"ControlTableViewController"];
    
    // setup sort discriptor for macro and commands
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    self.sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];

    
    return self;
}


- (NSMutableArray *)getMacroInfoForDevice:(Device *)device {
    
    
    return [self buildTableSectionsFromArray:[device.macros allObjects]];
    
}

- (NSMutableArray *)buildTableSectionsFromArray:(NSArray *)macros {
    
    // sort inputs
    self.sortedMacros = [self sortMacros:macros];
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    
    
    for (int i = 0; i < [self.sortedMacros count]; i++) {
        
        Macro  *macro = [self.sortedMacros objectAtIndex:i];
        
        UITableViewCell *displayCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceControl"];
        [displayCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIButton *macroButton = [self createMacroButtonWithConstraintsInCell:displayCell];
        
        [macroButton setTag:i];
        [[macroButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [[macroButton layer] setBorderWidth:2.0f];
        [[macroButton layer] setCornerRadius:10.0f];
       
        [macroButton addTarget:self.parentViewController action:@selector(macroTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
        [macroButton addTarget:self.parentViewController action:@selector(macroTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];

        [macroButton setTitle:macro.name forState:UIControlStateNormal];
        
        [list addObject:displayCell];
        
        [self.tableSections addObject:list];
        
    }
    
    return self.tableSections;
    
}



- (NSArray *)sortMacros:(NSArray *)macros {
    
    // sort relays by number
    return [macros sortedArrayUsingDescriptors:self.sortDescriptors];
    
}

// process selected commands from ControlTableViewController
- (void)performTouchDownCommandsForMacro:(NSNumber *)macroIndex {
    
    // get the selected macro
    Macro *macro = [self.sortedMacros objectAtIndex:[macroIndex intValue]];
    
    // get all commands for the macro
    self.macroCommands = [macro.commands allObjects];
    
    // get all touch down commands sorted in order entered
    NSPredicate *commandPredicate = [NSPredicate predicateWithFormat:@"event = %@", @"TouchDown"];
    
    NSArray *touchDownCommands = [self.macroCommands filteredArrayUsingPredicate:commandPredicate];
    NSArray *sortedTouchDownCommands = [touchDownCommands sortedArrayUsingDescriptors:self.sortDescriptors];
    
    if ([sortedTouchDownCommands count] > 0) {
        // execute touchDown commands
        [[MacroControl sharedInstance] performMacroCommands:sortedTouchDownCommands];

    }

}

- (void)performTouchUpCommandsForMacro {
    
    // get all touch down commands sorted in order entered
    NSPredicate *commandPredicate = [NSPredicate predicateWithFormat:@"event = %@", @"TouchUp"];
    
    NSArray *touchUpCommands = [self.macroCommands filteredArrayUsingPredicate:commandPredicate];
    NSArray *sortedTouchUpCommands = [touchUpCommands sortedArrayUsingDescriptors:self.sortDescriptors];
    
    if ([sortedTouchUpCommands count] > 0) {
        // execute touchUp commands
        [[MacroControl sharedInstance] performMacroCommands:sortedTouchUpCommands];
        
    }
    

    
}


// create restraints on progress view
- (UIButton *)createMacroButtonWithConstraintsInCell:(UITableViewCell *)displayCell {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // add to cell now so restraints will work
    [displayCell.contentView addSubview:button];
    
    // autolayout restraint to use the entire cell width
    // use only restraints specified here
    button.translatesAutoresizingMaskIntoConstraints = NO;
    // restraint for height
    NSLayoutConstraint *buttonHeight = [NSLayoutConstraint constraintWithItem:button
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                     constant:30];  //        [macroButton setFrame:CGRectMake(20, 7, 280, 30)];

    [button addConstraint:buttonHeight];
    
    // restraint for bottom
    NSLayoutConstraint *buttonBottom = [NSLayoutConstraint constraintWithItem:button
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:displayCell
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:-5];
    
    
    
    [displayCell addConstraint:buttonBottom];
    
    
    // restraint for left padding
    NSLayoutConstraint *buttonLeft = [NSLayoutConstraint constraintWithItem:button
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:displayCell
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:20];
    
    [displayCell addConstraint:buttonLeft];
    
    // restraint for right padding
    NSLayoutConstraint *buttonRight = [NSLayoutConstraint constraintWithItem:button
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:displayCell
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:-20];
    
    [displayCell addConstraint:buttonRight];
    
    return button;
}




@end
