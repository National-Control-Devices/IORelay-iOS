//
//  ControlTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/17/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device+Access.h"

typedef enum {
    Relays,
    Inputs,
    Macros,
} DisplayInfo;


@interface ControlTableViewController : UITableViewController

@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSTimer *inputTimer;


- (void)setSelectedDevice:(Device *)device;

- (void)relayButtonPressed:(id)sender;
- (void)momentaryRelayButtonPressed:(id)sender;
- (void)momentaryRelayButtonReleased:(id)sender;
- (void)macroTouchDownEvent:(id)sender;
- (void)macroTouchUpEvent:(id)sender;
@end
