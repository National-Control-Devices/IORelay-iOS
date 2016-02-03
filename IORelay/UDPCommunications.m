//
//  UDPCommunications.m
//  IORelay
//
//  Created by John Radcliffe on 10/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "UDPCommunications.h"
#import "DiscoveredDevice+Access.h"


static UDPCommunications *_sharedInstance;


@implementation UDPCommunications

# pragma mark - Object Lifecycle
+ (UDPCommunications *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[UDPCommunications alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    self.commonNetworkRoutines = [[CommonNetworkRoutines alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectSockets) name:@"DisconnectUDPSockets" object:nil];


    return self;
}

# pragma mark - Get current SSID

- (NSString *)getNetworkSSID {
    
    return [self.commonNetworkRoutines getNetworkSSID];
    
}

# pragma mark - Save current core data context

- (void)saveMOC:(NSManagedObjectContext *)context {
    
    self.context = context;
    
    [self setupSockets];
    
}



# pragma mark - Setup Sockets to listen on port 55555 & 13000

- (void)setupSockets
{
    // Setup our socket.
    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
    //
    // Now we can configure the delegate dispatch queues however we want.
    // We could simply use the main dispatc queue, so the delegate methods are invoked on the main thread.
    // Or we could use a dedicated dispatch queue, which could be helpful if we were doing a lot of processing.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDiscoveryActivityIndicator" object:nil userInfo:nil];

    // setup error
    NSError *error = nil;
    
    if (self.udpWifiSocket == nil) {
        // initialize socket for port 555
        self.udpWifiSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        if (![self.udpWifiSocket bindToPort:55555 error:&error])
        {
            NSLog(@"Error binding: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDiscoveryActivityIndicator" object:nil userInfo:nil];

            return;
        }
        if (![self.udpWifiSocket beginReceiving:&error])
        {
            NSLog(@"Error receiving: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDiscoveryActivityIndicator" object:nil userInfo:nil];

            return;
        }

    }
    
    if (self.udpSocket == nil) {
        // initialize socket for port 13000
        self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        if (![self.udpSocket bindToPort:13000 error:&error])
        {
            NSLog(@"Error binding: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDiscoveryActivityIndicator" object:nil userInfo:nil];

            return;
        }
        if (![self.udpSocket beginReceiving:&error])
        {
            NSLog(@"Error receiving: %@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDiscoveryActivityIndicator" object:nil userInfo:nil];

            return;
        }

    }
    
}


# pragma mark - UDP socket delegate - process packets received

// this delegate will handle all returns from both sockets
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowDiscoveryActivityIndicator" object:nil userInfo:nil];
    
    // var used to determine if packet is Xport or Webi format
    NSString *type;
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // if we get a string then we have an Ethernet(Xport) or WEB-I(Xport Pro) depending on string format
    if (msg) {
        
        // load string into array
        NSArray *packetItems = [msg componentsSeparatedByString:@","];
        
        // ethernet(Xport)
        if ([packetItems count] == 5) {
            type = (NSString *)[[packetItems objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([type isEqualToString:@"XPort"]) {
                [self processEthernetPacket:packetItems];

            }
        // WEB-I(Xport Pro)
        } else if ([packetItems count] == 4) {
            type = (NSString *)[[packetItems objectAtIndex:2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([type isEqualToString:@"Webi"]) {
                [self processWEBIPacket:packetItems];

            }
            
        }
        
    // we have a WiFi on port 55555
    } else {
        
        [self processWiFiPacket:data];
    }
    
    [self performSelector:@selector(hideActivityIndicatorWithDelay) withObject:nil afterDelay:1.0];
    
    
}

- (void)hideActivityIndicatorWithDelay {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideDiscoveryActivityIndicator" object:nil userInfo:nil];

}

// process string packets
- (void)processWEBIPacket:(NSArray *)packetItems {
    
    // build dictionary of info to create device
    NSDictionary *deviceInfo = @{@"name" : @"New WEBI Device",
                                 @"macAddress" : [packetItems objectAtIndex:1],
                                 @"ipAddress" : [packetItems objectAtIndex:0],
                                 @"networkSSID" : [self.commonNetworkRoutines getNetworkSSID],
                                 @"port" : [NSNumber numberWithInt:2101],
                                 @"type" : @"WEBI"
                                 };
    
    
    [DiscoveredDevice createDeviceFrom:deviceInfo InContext:self.context];

}

- (void)processEthernetPacket:(NSArray *)packetItems {
    
    // build dictionary of info to create device
    NSDictionary *deviceInfo = @{@"name" : @"New Ethernet Device",
                                 @"macAddress" : [packetItems objectAtIndex:1],
                                 @"ipAddress" : [packetItems objectAtIndex:0],
                                 @"networkSSID" : [self.commonNetworkRoutines getNetworkSSID],
                                 @"port" : [NSNumber numberWithInt:[[packetItems objectAtIndex:2] intValue]],
                                 @"type" : @"Ethernet"
                                 };

    
    [DiscoveredDevice createDeviceFrom:deviceInfo InContext:self.context];
    
}



- (void)processWiFiPacket:(NSData *)data {
    
//    NSLog(@"data length = %d", [data length]);
    
    if ([data length] == 120) {
        NSString *macAddress = [self convertMacAddress:[data subdataWithRange:NSMakeRange(110, 6)]];
        NSString *ipAddress = [self convertIPAddress:[data subdataWithRange:NSMakeRange(116, 4)]];
        NSNumber *port = [self convertPort:[data subdataWithRange:NSMakeRange(8, 2)]];
        NSString *signalStrength = [self convertSignalStrength:[data subdataWithRange:NSMakeRange(7, 1)]];
        
        // build dictionary of info to create device
        NSDictionary *deviceInfo = @{@"name" : @"New WiFi Device",
                                     @"macAddress" : macAddress,
                                     @"ipAddress" : ipAddress,
                                     @"networkSSID" : [self.commonNetworkRoutines getNetworkSSID],
                                     @"port" : port,
                                     @"signalStrength" : signalStrength,
                                     @"type" : @"WiFi"
                                     };
        
        
        [DiscoveredDevice createDeviceFrom:deviceInfo InContext:self.context];

        
    }
    
    
}

- (NSString *)convertMacAddress:(NSData *)data {
    
    NSString *string1stBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(0, 1)]];
    NSString *string2ndBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(1, 1)]];
    NSString *string3rdBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(2, 1)]];
    NSString *string4thBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(3, 1)]];
    NSString *string5thBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(4, 1)]];
    NSString *string6thBtye = [self.commonNetworkRoutines convertDataRangeToString:[data subdataWithRange:NSMakeRange(5, 1)]];

    
    NSString *macAddress = [NSString stringWithFormat:@"%@%@%@%@%@%@", string1stBtye, string2ndBtye, string3rdBtye, string4thBtye, string5thBtye, string6thBtye];
    return macAddress;
}

- (NSString *)convertIPAddress:(NSData *)data {
    
    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
    int int2ndByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(1, 1)]];
    int int3rdByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(2, 1)]];
    int int4thByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(3, 1)]];

    NSString *ipAddress = [NSString stringWithFormat:@"%d.%d.%d.%d", int1stByte, int2ndByte, int3rdByte, int4thByte];
    
    return ipAddress;
}

- (NSNumber *)convertPort:(NSData *)data {
    
    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
    
    int int2ndByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(1, 1)]];

    int port = (int1stByte * 256) + int2ndByte;
    
    NSNumber *portNum = [NSNumber numberWithInt:port];
    
    return portNum;
    
}

- (NSString *)convertSignalStrength:(NSData *)data {
    
    int int1stByte = [self.commonNetworkRoutines convertDataRangeToInt:[data subdataWithRange:NSMakeRange(0, 1)]];
    
    NSString *signalStrength = [NSString stringWithFormat:@"%d", int1stByte];
    
    // TODO: additional code to convert 44 to Very Good...
    
    return signalStrength;
}


- (void)disconnectSockets {
    
    if (self.udpSocket != nil) {
        [self.udpSocket close];
        self.udpSocket = nil;

    }
    
    if (self.udpWifiSocket != nil) {
        [self.udpWifiSocket close];
        self.udpWifiSocket = nil;

    }
    
   }

//- (int)convertDataRangeToInt:(NSData *)data {
//    
//    unsigned char *n = (unsigned char *)[data bytes];
//    return *(int *)n;
//
//    
//}

//- (NSString *)convertDataRangeToString:(NSData *)data {
//    
//    unsigned char *s = (unsigned char *)[data bytes];
//    
//    NSUInteger sBytes = [data length];
//    
//    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:sBytes];
//    
//    for(NSUInteger i=0; i<sBytes; i++ ) {
//        [hex appendFormat:@"%02X", s[i]];
//        
//    }
//    return hex;
//}
//    




@end
