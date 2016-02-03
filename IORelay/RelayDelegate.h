//
//  RelayDelegate.h
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "ControlTableViewController.h"

@interface RelayDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *tableSections;
@property (nonatomic, strong) ControlTableViewController *parentViewController;

@property (strong, nonatomic) NSArray *relayStatus;

+ (RelayDelegate *)sharedInstance;

- (NSMutableArray *)getRelayInfoForDevice:(Device *)device;

- (void)requestAllRelaysStatus;
- (void)toggleRelay:(NSNumber *)relay;
- (void)toggleMomentaryRelay:(NSNumber *)relay withAction:(NSString *)action;


@end
