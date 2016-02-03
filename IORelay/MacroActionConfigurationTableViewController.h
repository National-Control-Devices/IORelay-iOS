//
//  MacroActionConfigurationTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"
#import "MacroCommand+Access.h"

@interface MacroActionConfigurationTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) Macro *macro;

@property (strong, nonatomic) MacroCommand* macroCommand;

@property (strong, nonatomic) NSString *eventType;

- (void)setSelectedMacro:(Macro *)macro;
- (void)setSelectedMacroCommand:(MacroCommand *)command;


@end
