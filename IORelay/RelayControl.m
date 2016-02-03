//
//  RelayControl.m
//  IORelay
//
//  Created by John Radcliffe on 10/25/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "RelayControl.h"
#import "TCPCommunications.h"

static RelayControl *_sharedInstance;


@implementation RelayControl

# pragma mark - Object Lifecycle
+ (RelayControl *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RelayControl alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    self.commonNetworkRoutines = [[CommonNetworkRoutines alloc] init];
    
    // observe from TCPCommunications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStatusAllRelaysReply:) name:@"ProcessStatusAllRelaysReply" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStatusFusionReply:) name:@"ProcessStatusFusionReply" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processToggleRelayOnOffReply:) name:@"ProcessToggleRelayOnOffReply" object:nil];

    
    return self;
}


# pragma mark - RELAYS


// get status of all relays for display
- (void)requestAllRelaysStatus {
    
    self.relayStatus = [[NSMutableArray alloc] init];
    
    NSData *data = [self.commonNetworkRoutines buildAPIPacket:@[[NSNumber numberWithInt:commandHeader],[NSNumber numberWithInt:124],[NSNumber numberWithInt:0]]];
    [[TCPCommunications sharedInstance] writeDataToSocket:data withTag:GetStatusAllRelays];
    
}


- (void)processStatusAllRelaysReply:(NSNotification *)notification {
    
    NSData *data = [[notification userInfo] valueForKey:@"responseData"];
    
    self.relayStatus = [[NSMutableArray alloc] init];
    
    // start at 3rd byte - this throws away 170, 32 and starts with our data either a 0(off) or 1(on)
    for (int i = 2; i < ([data length] -1); i++) {  // throw away the last byte - it's the checksum
        int intByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(i, 1)]];
        
        // if we have a value we need to convert it to look at all relays in this bank
        //        if (intByte > 0) {
        //            NSString *relays = [self decToBinary:intByte];
        NSString *relays = [self reverseString:[self intToBinary:intByte]];
        
        
        // convert to binary and reverse the order so relay 1 is in position 0  - just so it's easier to work with
        for (int j = 0; j < [relays length]; j++) {
            NSString *relayBool = [[NSString alloc]initWithString:[relays substringWithRange:NSMakeRange(j, 1)]];
            [self.relayStatus addObject:relayBool];
            
        }
        
    }
    
    // tell ControlTableViewController to refresh the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewNeedsUpdate" object:nil];
    
    [[CommonRoutines sharedInstance] vibrateMe];
    
}

- (void)processStatusFusionReply:(NSNotification *)notification {
    
    NSData *data = [[notification userInfo] valueForKey:@"responseData"];
    
    // do not initialize relay status
    // TODO: verify we still have the correct values
//    self.relayStatus = [[NSMutableArray alloc] init];
    
    // we only get a single byte back from the fusion controllers
    int intByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(3, 1)]];
        
   // convert to binary and reverse the order so relay 1 is in position 0  - just so it's easier to work with
    NSString *relays = [self reverseString:[self intToBinary:intByte]];
    
    // get the status for the relay that has been updated
    NSString *relayBool = [[NSString alloc]initWithString:[relays substringWithRange:NSMakeRange([self.selectedRelayInBank intValue], 1)]];

    //update relayStatus in our tableview
    [self.relayStatus removeObjectAtIndex:[self.selectedRelayIndex intValue]];
    [self.relayStatus insertObject:relayBool atIndex:[self.selectedRelayIndex intValue]];

    // tell ControlTableViewController to refresh the table
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewNeedsUpdate" object:nil];
    
    [self delayedRefreshRelayToggle];
    
    [[CommonRoutines sharedInstance] vibrateMe];
    
}

// allow toggle of multiple relays within a 1/4 sec timeframe and only updated ui when done
-(void)delayedRefreshRelayToggle {
    
    if (self.fusionRelayTimer != nil && [self.fusionRelayTimer isValid]) {
        [self.fusionRelayTimer invalidate];
        self.fusionRelayTimer = nil;
    }
    
    self.fusionRelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(refreshRelays) userInfo:nil repeats:NO];
    
}

-(void)refreshRelays {
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewNeedsUpdate" object:nil];
    
}



- (NSString *)reverseString:(NSString *)string
{
    NSMutableString *reversedStr;
    int len = [string length];
    
    // auto released string
    reversedStr = [NSMutableString stringWithCapacity:len];
    
    // quick-and-dirty implementation
    while ( len > 0 )
        [reversedStr appendString:[NSString stringWithFormat:@"%C",[string characterAtIndex:--len]]];
    
    return reversedStr;
}


- (NSString *)intToBinary:(int)intValue
{
    int byteBlock = 8,    // 8 bits per byte
    totalBits = sizeof(int) * byteBlock, // Total bits
    binaryDigit = 1;  // Current masked bit
    
    // Binary string
    NSMutableString *binaryStr = [[NSMutableString alloc] init];
    
    do
    {
        // Check next bit, shift contents left, append 0 or 1
        [binaryStr insertString:((intValue & binaryDigit) ? @"1" : @"0" ) atIndex:0];
        
        // More bits? On byte boundary ?
        if (--totalBits && !(totalBits % byteBlock))
            return binaryStr;
        //            [binaryStr insertString:@"|" atIndex:0];
        
        // Move to next bit
        binaryDigit <<= 1;
        
    } while (totalBits);
    
    // Return binary string
    return binaryStr;
}

// change selected relay state
- (void)toggleRelay:(NSNumber *)relay fromState:(NSNumber *)currentState {
    NSLog(@"toggle relay");
    // convert bank
    NSNumber *bank = [self calculateBankFromRelay:relay];
    
    NSNumber *toggleRelay = [self calculateRelay:relay changeFromCurrentState:currentState];
    
    // if we are currently on - toggle to off
    if ([currentState boolValue]) {
        [self toggleRelayOnOff:toggleRelay inBank:bank withTag:TurnRelayOff];
        
        // we are currently off - so we toggle on
    } else {
        [self toggleRelayOnOff:toggleRelay inBank:bank withTag:TurnRelayOn];
        
    }
    
}

- (void)toggleMomentaryRelay:(NSNumber *)relay forState:(NSString *)state {
    // convert bank
    
    NSNumber *bank = [self calculateBankFromRelay:relay];
    NSNumber *toggleRelay;
    
    if ([state isEqualToString:@"On"]) {
        // we will be going from off to on state
        toggleRelay = [self calculateRelay:relay changeFromCurrentState:[NSNumber numberWithBool:NO]];
        [self toggleRelayOnOff:toggleRelay inBank:bank withTag:MomentaryRelayOn];

    } else if ([state isEqualToString:@"Off"]) {
        // we will be going from on to off state
        toggleRelay = [self calculateRelay:relay changeFromCurrentState:[NSNumber numberWithBool:YES]];
        [self toggleRelayOnOff:toggleRelay inBank:bank withTag:MomentaryRelayOff];

    }

}


- (NSNumber *)calculateBankFromRelay:(NSNumber *)relay {
    
    int bank = ceilf((([relay intValue] +1) / 8.0));
    
    return [NSNumber numberWithInt:bank];
    
}

- (NSNumber *)calculateRelay:(NSNumber *)relay changeFromCurrentState:(NSNumber *)currentState {
    
    // this is the table position for the relay 0 - ...
    // save this off incase we need it later for a fusion update
    self.selectedRelayIndex = relay;
    
    // convert this to associated relay command number
    int selectedRelay = [self.selectedRelayIndex intValue] + 100; //this works for relays 1-8 but not for higher numbers (we need to always have a value from 100 - 107
    
    // convert relay down to associated 100 - 107 from higher numbers which represent additonal banks
    while (selectedRelay > 107) {
        selectedRelay = selectedRelay - 8;
    }
    
    // save the relay position for the bank incase we need it later for a fusion update
    self.selectedRelayInBank = [NSNumber numberWithInt:(selectedRelay -100)];
    
    // turn off commands 100 - 107 - so we don't need to change
    // however, turn on commands 108 - 115 we'll need to add 8 to our calculated value
    if (![currentState boolValue]) { // we're going from off to on state
        selectedRelay = selectedRelay +8;
    }
    
    return [NSNumber numberWithInt:selectedRelay];
}

// Send Command to toggle relay
- (void)toggleRelayOnOff:(NSNumber *)relay inBank:(NSNumber *)bank withTag:(ReadWriteTag)tag {
    
    NSData *data = [self.commonNetworkRoutines buildAPIPacket:@[[NSNumber numberWithInt:commandHeader],relay,bank]];
    [[TCPCommunications sharedInstance] writeDataToSocket:data withTag:tag];

}

- (void)processToggleRelayOnOffReply:(NSNotification *)notification {
    
//    NSData *data = [[notification userInfo] valueForKey:@"responseData"];
    
//    // breakout 3rd byte to see if we have a fusion controller
//    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
//    int int2ndByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(1, 1)]];
//    int int3rdByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(2, 1)]];
//    int int4thByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(3, 1)]];
    
        
    [self updateRelayStatus];
    
    
}

- (void)updateRelayStatus {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RelaysNeedUpdate" object:nil];
    
}

// pass relay status back to relay delegate for table update
- (NSArray *)getAllRelayStatus {
    
    return self.relayStatus;
}



@end
