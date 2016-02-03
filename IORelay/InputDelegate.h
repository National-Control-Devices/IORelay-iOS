//
//  InputDelegate.h
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControlTableViewController.h"
#import "Device.h"
#import "CalculateInputValue.h"

@interface InputDelegate : NSObject


@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) ControlTableViewController *parentViewController;
@property (nonatomic, strong) NSArray *inputStatus;
@property (nonatomic, strong) CalculateInputValue *calculateInputValue;

+ (InputDelegate *)sharedInstance;

- (NSMutableArray *)getInputInfoForDevice:(Device *)device;
- (void)requestAllInputsStatus;


@end
