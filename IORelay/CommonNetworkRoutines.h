//
//  CommonNetworkRoutines.h
//  IORelay
//
//  Created by John Radcliffe on 10/22/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>

static int commandHeader = 254;

typedef enum {
    CheckDeviceType = 1, // tag 1 = check for fusion controller
    Test2WayCommunications,  // test communications with device - testing only
    GetStatusAllRelays,     // get status of relays
    TurnRelayOff,
    TurnRelayOn,
    GetStatusAllInputs,
    MomentaryRelayOn,
    MomentaryRelayOff,
    ProcessTouchDownCommands,
    ProcessTouchUpCommands
} ReadWriteTag;


@interface CommonNetworkRoutines : NSObject

- (NSString *)getNetworkSSID;
- (NSData *)buildAPIPacket:(NSArray *)commands;
- (int)convertDataRangeToInt:(NSData *)data;
- (NSString *)convertDataRangeToString:(NSData *)data;

@end
