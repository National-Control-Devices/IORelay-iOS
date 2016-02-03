//
//  UDPCommunications.h
//  IORelay
//
//  Created by John Radcliffe on 10/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "CommonNetworkRoutines.h"



@interface UDPCommunications : NSObject

@property (nonatomic, strong) NSString *currentNetworkSSID;

@property (nonatomic, strong) GCDAsyncUdpSocket *udpWifiSocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) CommonNetworkRoutines *commonNetworkRoutines;



+ (UDPCommunications *)sharedInstance;

- (NSString *)getNetworkSSID;
//- (void)setupSockets;

- (void)saveMOC:(NSManagedObjectContext *)context;

- (void)disconnectSockets;

@end
