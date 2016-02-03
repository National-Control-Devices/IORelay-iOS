//
//  MacroDelegate.h
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControlTableViewController.h"
#import "Device.h"

@interface MacroDelegate : NSObject

@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) ControlTableViewController *parentViewController;

@property (nonatomic, strong) NSArray *sortedMacros;
@property (nonatomic, strong) NSArray *macroCommands;
@property (nonatomic, strong) NSArray *sortDescriptors;


+ (MacroDelegate *)sharedInstance;

- (NSMutableArray *)getMacroInfoForDevice:(Device *)device;
- (void)performTouchDownCommandsForMacro:(NSNumber *)macro;
- (void)performTouchUpCommandsForMacro;



@end
