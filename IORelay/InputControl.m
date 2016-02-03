//
//  InputControl.m
//  IORelay
//
//  Created by John Radcliffe on 10/30/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputControl.h"
#import "TCPCommunications.h"

static InputControl *_sharedInstance;

@implementation InputControl

# pragma mark - Object Lifecycle
+ (InputControl *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[InputControl alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    self.commonNetworkRoutines = [[CommonNetworkRoutines alloc] init];
    
//    // observe from TCPCommunications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processStatusAllInputsReply:) name:@"ProcessStatusAllInputsReply" object:nil];
    
    
    return self;
}

// get status of all relays for display
- (void)requestAllInputsStatus {
    
//    //    self.allRelayStatusResponseData = [[NSMutableData alloc] init];
//    self.inputStatus = [[NSMutableArray alloc] init];
    
    NSData *data = [self.commonNetworkRoutines buildAPIPacket:@[[NSNumber numberWithInt:commandHeader],[NSNumber numberWithInt:167]]];
    [[TCPCommunications sharedInstance] writeDataToSocket:data withTag:GetStatusAllInputs];
    
}


- (void)processStatusAllInputsReply:(NSNotification *)notification {
    
    NSData *data = [[notification userInfo] valueForKey:@"responseData"];
    
    // there are always 8 inputs??
    self.inputStatus = [[NSMutableArray alloc] initWithCapacity:8];
    
    int msb = 0;
    int lsb = 0;
    
    // start at 3rd byte - this throws away 170, 16 and starts with our data
    // separate the MSB (first 8 bytes) from the LSB (last 8 bytes)
    for (int i = 2; i < ([data length] -1); i++) {  // ([data length] -1)throw away the last byte - it's the checksum
        int intByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(i, 1)]];
    
       // is i odd
        if (i % 2) {
            lsb = intByte;
            
            // save off msb / lsb for this input and we will calculate display value in inputDelegate
            NSDictionary *inputValues = @{@"msb" : [NSNumber numberWithInt:msb],
                                          @"lsb" : [NSNumber numberWithInt:lsb]};
            
            
            // calculate the input values and store in array based on type of input designated
            [self.inputStatus addObject:inputValues];

        // else i is even
        } else {
            // save off the msb byte
            msb = intByte;
   
        }
    }
    
    // tell ControlTableViewController to refresh the table
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewNeedsUpdate" object:nil];
    
}


// pass relay status back to relay delegate for table update
- (NSArray *)getAllInputsStatus {
    
    return self.inputStatus;
}


@end
