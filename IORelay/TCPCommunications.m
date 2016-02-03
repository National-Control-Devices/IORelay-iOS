//
//  TCPCommunications.m
//  IORelay
//
//  Created by John Radcliffe on 10/14/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "TCPCommunications.h"
#import <AFNetworking/AFNetworking.h> 


static TCPCommunications *_sharedInstance;

static NSString * const SignalSwitchBaseURL = @"http://link.signalswitch.com/getip.aspx?"; // mac=" + macAddress);

static int waitTime = 3.0;

@implementation TCPCommunications

# pragma mark - Object Lifecycle
+ (TCPCommunications *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TCPCommunications alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    self.commonNetworkRoutines = [[CommonNetworkRoutines alloc] init];
    
    self.relayStatusResponseData = [[NSMutableData alloc] init];
    self.toggleRelayResponseData = [[NSMutableData alloc] init];
    self.momentaryRelayResponseData = [[NSMutableData alloc] init];
    self.inputStatusResponseData = [[NSMutableData alloc] init];
    self.macroResponseData = [[NSMutableData alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectSockets) name:@"DisconnectTCPSockets" object:nil];
    
    return self;
}

# pragma mark - Get current SSID

- (NSString *)getNetworkSSID {
    
    return [self.commonNetworkRoutines getNetworkSSID];
}

# pragma mark - Save current core data context

- (void)saveMOC:(NSManagedObjectContext *)context {
    
    self.context = context;
    
}


// We are on the same network so check for our device
- (void)verifyNetworkConnectivityToDevice:(Device *)device {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowActivityIndicator" object:nil userInfo:nil];

    self.device = device;
    
    if (self.asyncSocket != nil) {
        [self.asyncSocket disconnect];
        self.asyncSocket = nil;
    }

    NSDictionary *deviceInfo = @{
                                 @"ipAddress" : self.device.ipAddress,
                                 @"port" : self.device.port
                                 };
    
    self.isRemote = NO;
    self.remoteDeviceInfo = nil;
    self.isDeviceTypeSet = NO;

    // delay added here to allow time for the disconnect to happen before continuing
    [self performSelector:@selector(setupSocketToDeviceAt:) withObject:deviceInfo afterDelay:0.5];
    
}

// Not on the same network so use signalswitch to communicate with device
- (void)verifySignalSwitchConnectivityToDevice:(Device *)device {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowActivityIndicator" object:nil userInfo:nil];

    self.device = device;
    
    if (self.asyncSocket != nil) {
        [self.asyncSocket disconnect];
        self.asyncSocket = nil;
    }


    NSString *urlString = [NSString stringWithFormat:@"%@mac=%@",SignalSwitchBaseURL, self.device.macAddress];
    NSURL * signalSwitchURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:signalSwitchURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseString = [NSString stringWithUTF8String:[responseObject bytes]];
        NSArray *myArray = [responseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        
        NSString *ipAddress = [myArray objectAtIndex:0];
        
        if ([ipAddress isEqualToString:@"Device not found"]) {
            
            // display alert - not found
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];

            NSDictionary *userInfo = @{@"title" : @"Device not found!", @"error" : @"No device information found for remote access"};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];
            
        } else {
            // attempt connection
            NSNumber *port;
            
            if(![device.type isEqualToString:@"WEBI"]){
                NSLog(@"device not WEBi");
                port = [NSNumber numberWithInt:[[myArray objectAtIndex:1] intValue]];
            }else{
                NSLog(@"its a webi");
                port = device.port;
            }
            
            self.remoteDeviceInfo = @{
                                    @"ipAddress" : ipAddress,
                                    @"port" : port
                                    };
            self.isRemote = YES;
            self.isDeviceTypeSet = NO;
            [self setupSocketToDeviceAt:self.remoteDeviceInfo];
            

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];
        
        // display alert - could not connect to signalswitch
        NSDictionary *userInfo = @{@"title" : @"No Connection!", @"error" : @"Could not connect to remote server"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:self userInfo:userInfo];
        

    }];
    
    [operation start];
    
}


# pragma mark - asyncsocket connection

- (void)setupSocketToDeviceAt:(NSDictionary *)deviceInfo {
    
    
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    uint16_t port = [[deviceInfo objectForKey:@"port"] intValue];
    NSString *ipAddress = [deviceInfo objectForKey:@"ipAddress"];
    
    NSLog(@"connecting to controller over IP Address: %@ on port %i", ipAddress, port);
    
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:ipAddress onPort:port error:&error])
    {
        NSLog(@"failed to connect");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];

        NSString *connectionStatus = [NSString stringWithFormat:@"Could not connect with device\n %@", error];
        
        // pass response data back to relayControl for processing
        NSDictionary *userInfo = @{@"title" : @"Error Initializing Device", @"error" : connectionStatus};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];

    }
   
}

# pragma mark - connection delegates
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];
    
    //Tcheck for device type Fusion?
    if (!self.isDeviceTypeSet) {
        [self checkDeviceType];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
    NSString *errorMessage;
    
    // we disconnect after each remote command so don't check...
//    if (!self.isRemote) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"HideActivityIndicator" object:nil userInfo:nil];
//
//    }
    
    if (self.isToggleRelayTimeout) {
        [self verifyNetworkConnectivityToDevice:self.device];
        
        [self performSelector:@selector(refreshRelayDisplay) withObject:nil afterDelay:2.0];
        
        self.isToggleRelayTimeout = NO;
    } else {
    
         // communications with device failed
        if (err != nil) {
            
            switch (err.code) {
                case 60:
                    errorMessage = @"Operation timed out";
                    break;
                    
                default:
                    errorMessage = @"Reconnect?";
                    break;
            }
        
            // update device info
            [Device updateInfoForDevice:self.device InContext:self.context];
            
            // ask user what to do?
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                            message:errorMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Local", @"Remote", nil];
            [alert show];
            

        }
    }
        

//socketDidDisconnect:0x15d6e680 withError: Error Domain=GCDAsyncSocketErrorDomain Code=4 "Read operation timed out" UserInfo=0x15d39cb0 {NSLocalizedDescription=Read operation timed out}    
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    // process device reconnect request - local
    if (buttonIndex == 1) {
        
        [self verifyNetworkConnectivityToDevice:self.device];
        
        [self performSelector:@selector(refreshRelayDisplay) withObject:nil afterDelay:2.0];
        
    // process device reconnect request - remote
    } else if (buttonIndex == 2) {
        
        [self verifySignalSwitchConnectivityToDevice:self.device];
        
        [self performSelector:@selector(refreshRelayDisplay) withObject:nil afterDelay:2.0];

    }
    
        
}

- (void)refreshRelayDisplay {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RelaysNeedUpdate" object:nil];

}

# pragma mark - communicate with device from relay/control/macro control classes

// send command to socket
- (void)writeDataToSocket:(NSData *)data withTag:(int)tag {
    
    // if we are remote - setup socket for each read/write
    if (self.isRemote) {
        
        if ([self.asyncSocket isDisconnected]) {
            [self setupSocketToDeviceAt:self.remoteDeviceInfo];
        }
        

    }
    
    if ([self.asyncSocket isConnected]) {
        
        // set socket to read for the tag we are about to write
        [self.asyncSocket readDataWithTimeout:waitTime tag:tag];
        //    [self.asyncSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:tag];
        
        // write command to socket
        [self.asyncSocket writeData:data withTimeout:waitTime tag:tag];
        

    } else {
       
//        // if error Code=64 "Host is down  - allow the user to reconnect
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Lost"
//                                                        message:@"Reconnect?"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Remote", @"Local", nil];
//        [alert show];
//
    
    }
    
}

# pragma mark - asyncsocket write to device delegates
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    

}


# pragma mark - asyncsocket read data from device delegates
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    

    switch (tag) {
            
//DEVICE RESPONSES
        case CheckDeviceType: {
            [self processCheckDeviceTypeResponse:data];
            
            // tell DeviceList that we have comms with the device so proceed to ControlTableViewController
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceCommunicationEstablished" object:nil];

            break;
        }
            
        case Test2WayCommunications: {
            
            [self process2WayCommunicationsReply:data];
            
            break;
        }

            
//RELAY RESPONSES            
        case GetStatusAllRelays: {
            
//            NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
            
            // else append response to buffer until we get all bytes
            [self.relayStatusResponseData appendData:data];
//            NSLog(@"data = %@", data);
//            NSLog(@"self.relayresponseData = %@", self.relayStatusResponseData);
            
            // if we hit this scenario we have a ToggleON/OFF response that has gotten mixed up and has responded to us with a tag of 3 (GetStatusAllRElays)
            if ([self.relayStatusResponseData length] > 1) {
                // get the value of the 2nd byte if whe only have 1 command - this is a ToggleON/OFF response
                if ([self getResponseByteCount:self.relayStatusResponseData] == 1) {
                    
                    if ([self.relayStatusResponseData length] < 4) {  // make sure we have all 4 bytes
                        [self.asyncSocket readDataWithTimeout:waitTime tag:GetStatusAllRelays];
                        // process return
                    } else {
                        [self checkSumIsValid:self.relayStatusResponseData];
                        // pass response data back to relayControl for processing
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.relayStatusResponseData forKey:@"responseData"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusAllRelaysReply" object:nil userInfo:userInfo];
                        // initialize nsdata to hold relay response
                        self.relayStatusResponseData = [[NSMutableData alloc] init];
                        NSLog(@"Returning");
                        break;
                    }

                } else {
                    
                    // requeue read immediately
                    if ([self.relayStatusResponseData length] < 35) {  // 35 bytes = command returns 170 + 32 +(the 32 bytes of data) + checksum
                        [self.asyncSocket readDataWithTimeout:waitTime tag:GetStatusAllRelays];
                        // process return
                    } else {
                        
                        // pass response data back to relayControl for processing
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.relayStatusResponseData forKey:@"responseData"];
                        NSLog(@"response data = %@", self.relayStatusResponseData);
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusAllRelaysReply" object:nil userInfo:userInfo];
                        
                        // initialize nsdata to hold relay response
                        self.relayStatusResponseData = [[NSMutableData alloc] init];

                    }

                }
                
            } else {
                [self.asyncSocket readDataWithTimeout:waitTime tag:GetStatusAllRelays];
            }
           
            
            
            break;
        }

            
        case TurnRelayOff:
        case TurnRelayOn: {
            
            // this is the status response from a fusion controller
            if (self.isFusion) {
                
//TODO: do we need to verify that we get 4 bytes back from the fusion controller as a response to being toggled?
                // pass response data back to relayControl for processing
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:data forKey:@"responseData"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusFusionReply" object:nil userInfo:userInfo];
                
                break;
            }

            
            [self.toggleRelayResponseData appendData:data];
            
            // requeue read immediately
            if ([self.toggleRelayResponseData length] < 4) {  // 4 bytes = command returns 170 + 1 + status byte + checksum
                [self.asyncSocket readDataWithTimeout:waitTime tag:tag];
                // process return
            } else {
                // pass response data back to relayControl for processing
                NSDictionary *userInfo = @{@"responseData" : self.toggleRelayResponseData , @"tag" : [NSNumber numberWithLong:tag]};
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessToggleRelayOnOffReply" object:nil userInfo:userInfo];
                
                [self delayedRefreshRelayToggle:userInfo];

                
                // initialize nsdata to hold relay response
                self.toggleRelayResponseData = [[NSMutableData alloc] init];

            }
            break;
        }
            
        case MomentaryRelayOn:
        case MomentaryRelayOff: {
            
            // this is the status response from a fusion controller
            if (self.isFusion) {
                
                // pass response data back to relayControl for processing
//                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:data forKey:@"responseData"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusFusionReply" object:nil userInfo:userInfo];
//                
                break;
            }
            
            
            [self.momentaryRelayResponseData appendData:data];
            
            // requeue read immediately
            if ([self.momentaryRelayResponseData length] < 4) {  // 4 bytes = command returns 170 + 1 + status byte + checksum
                [self.asyncSocket readDataWithTimeout:waitTime tag:tag];
                // process return
            } else {
                // pass response data back to relayControl for processing
//                NSDictionary *userInfo = @{@"responseData" : self.responseData , @"tag" : [NSNumber numberWithLong:tag]};
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessToggleRelayOnOffReply" object:nil userInfo:userInfo];
                
                // initialize nsdata to hold relay response
                self.momentaryRelayResponseData = [[NSMutableData alloc] init];

            }
            break;
        }

            
//INPUTS RESPONSES
        case GetStatusAllInputs: {
            
            // else append response to buffer until we get all 35 bytes
            [self.inputStatusResponseData appendData:data];
            
            // requeue read immediately
            if ([self.inputStatusResponseData length] < 19) {  // 35 bytes = command returns 170 + 32 +(the 32 bytes of data) + checksum
                [self.asyncSocket readDataWithTimeout:waitTime tag:GetStatusAllInputs];
                // process return
            } else {
                
                // pass response data back to relayControl for processing
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.inputStatusResponseData forKey:@"responseData"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusAllInputsReply" object:nil userInfo:userInfo];
                
                // initialize nsdata to hold relay response
                self.inputStatusResponseData = [[NSMutableData alloc] init];

            }
            
            break;
        }
 
//MACRO RESPONSES
        case ProcessTouchDownCommands:
        case ProcessTouchUpCommands: {
            
            // this is the status response from a fusion controller
            if (self.isFusion) {
                
                // pass response data back to relayControl for processing
                //                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:data forKey:@"responseData"];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessStatusFusionReply" object:nil userInfo:userInfo];
                //
                break;
            }
            
            
            [self.macroResponseData appendData:data];
            
            // requeue read immediately
            if ([self.macroResponseData length] < 4) {  // 4 bytes = command returns 170 + 1 + status byte + checksum
                [self.asyncSocket readDataWithTimeout:waitTime tag:tag];
                // process return
            } else {
                // pass response data back to relayControl for processing
                //                NSDictionary *userInfo = @{@"responseData" : self.responseData , @"tag" : [NSNumber numberWithLong:tag]};
                //                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessToggleRelayOnOffReply" object:nil userInfo:userInfo];
                
                // initialize nsdata to hold relay response
                self.macroResponseData = [[NSMutableData alloc] init];

            }
            break;
        }

            
        default:
            break;
    }
    
}

// allow toggle of multiple relays within a 1/4 sec timeframe and only updated ui when done
-(void)delayedRefreshRelayToggle:(NSDictionary *)userInfo {
    
    if (self.relayTimer != nil && [self.relayTimer isValid]) {
        [self.relayTimer invalidate];
        self.relayTimer = nil;
    }
    
    self.relayTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(refreshRelays:) userInfo:userInfo repeats:NO];
    
}

-(void)refreshRelays:(NSTimer *)sender {
    
    NSDictionary *userInfo = sender.userInfo;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProcessToggleRelayOnOffReply" object:nil userInfo:userInfo];
    
}



# pragma mark - DEVICE
// find out if we have connected to a fusion controller
- (void)checkDeviceType {
    
    // queue a read socket so we are listening for response from controller
    [self.asyncSocket readDataToLength:4 withTimeout:waitTime tag:CheckDeviceType];

    // test for Fusion controller
    NSData *data = [self.commonNetworkRoutines buildAPIPacket:@[[NSNumber numberWithInt:commandHeader],[NSNumber numberWithInt:53],[NSNumber numberWithInt:244]]];
    
    [self.asyncSocket writeData:data withTimeout:waitTime tag:CheckDeviceType];
    
}

- (void)processCheckDeviceTypeResponse:(NSData *)data {
    
    // initialize fusion property
    self.isFusion = NO;
    self.isDeviceTypeSet = YES;
    
    if ([data length] == 4) {
        // breakout 3rd byte to see if we have a fusion controller
        int int3rdByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(2, 1)]];
        
        // test for fusion
        unsigned int fusion = int3rdByte & (unsigned int)128;
        
        if (fusion == (unsigned int)128) {
            self.isFusion = YES;
        } else {
            self.isFusion = NO;
            
        }

    }
    
    
}

// Test 2 way communications with the device
- (void)test2WayCommunications {
    
    [self.asyncSocket readDataToLength:4 withTimeout:waitTime tag:Test2WayCommunications];

    NSData *data = [self.commonNetworkRoutines buildAPIPacket:@[[NSNumber numberWithInt:commandHeader],[NSNumber numberWithInt:33]]];
    
    [self.asyncSocket writeData:data withTimeout:waitTime tag:Test2WayCommunications];
    
}

- (void)process2WayCommunicationsReply:(NSData *)data {
    
    // breakout 3rd byte to see if we have a fusion controller
//    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
//    int int2ndByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(1, 1)]];
//    int int3rdByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(2, 1)]];
//    int int4thByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(3, 1)]];


}

- (int)getResponseByteCount:(NSData *)data {
    
    // breakout 2nd byte to see if we have a lite? controller
    //    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
        int int2ndByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(1, 1)]];
    //    int int3rdByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(2, 1)]];
    //    int int4thByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(3, 1)]];
    
    
//    NSLog(@"int2ndByte = %d", int2ndByte);
    
    return int2ndByte;
    
    
}

- (BOOL)checkSumIsValid:(NSData *)data {
    
    int checkSum = 0;
    
    for (int i = 0; i < ([data length] -1);  i++) {
        int commandByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(i, 1)]];
        
        checkSum = checkSum + commandByte;
    }
    
    int lastByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(([data length] -1), 1)]];
    
    
    if ((checkSum&256) == lastByte) {
        return YES;
    }
    
    return NO;

}


/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length {
    NSLog(@"read timeout - tag = %ld", tag);
    
    // if we get a timeout waiting for getallrelaystatus response - we will just re-issue the command
    if (tag == 3) {
        self.isToggleRelayTimeout = YES;
    }

    // are read after the toggled relay on/off command timed out - it more than likely came back to us as a tag == 3 and was thrown away
    if (self.isToggleRelayResponseError) {
        self.isToggleRelayResponseError = NO;
        
        if (tag == 4 || tag == 5) {
            self.isToggleRelayTimeout = YES;
        }

    }
    
    return 0;
    
}
/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
          bytesDone:(NSUInteger)length {
    
    NSLog(@"write timeout tag = %ld", tag);
    
    return 0;
              
}

- (void)disconnectSockets {
    
    if (self.asyncSocket != nil) {
        [self.asyncSocket disconnect];
        self.asyncSocket = nil;
    }

}

@end
