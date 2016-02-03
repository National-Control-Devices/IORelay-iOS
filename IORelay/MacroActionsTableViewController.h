//
//  MacroActionsTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "Macro+Access.h"
#import "MacroCommand.h"

@interface MacroActionsTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) Macro *macro;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)setSelectedDevice:(Device *)device;
- (void)setSelectedMacro:(Macro *)macro;


@end
