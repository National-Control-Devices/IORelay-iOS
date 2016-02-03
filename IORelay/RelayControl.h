//
//  RelayControl.h
//  IORelay
//
//  Created by John Radcliffe on 10/25/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkRoutines.h"
#import "CommonRoutines.h"

@interface RelayControl : NSObject

@property (strong, nonatomic) NSMutableArray *relayStatus;
@property (nonatomic, strong) CommonNetworkRoutines *commonNetworkRoutines;

@property (nonatomic, strong) NSNumber *selectedRelayIndex;
@property (nonatomic, strong) NSNumber *selectedRelayInBank;

@property (nonatomic, strong) NSTimer *fusionRelayTimer;

+ (RelayControl *)sharedInstance;

- (void)requestAllRelaysStatus;
- (void)toggleRelay:(NSNumber *)relay fromState:(NSNumber *)currentState;
- (void)toggleMomentaryRelay:(NSNumber *)relay forState:(NSString *)state;
- (NSArray *)getAllRelayStatus;


@end
