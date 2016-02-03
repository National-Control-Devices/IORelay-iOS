//
//  TCPCommunications.h
//  IORelay
//
//  Created by John Radcliffe on 10/14/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device+Access.h"
#import "GCDAsyncSocket.h"
#import "CommonNetworkRoutines.h"

@interface TCPCommunications : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) NSString *currentNetworkSSID;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) Device *device;
@property (nonatomic) BOOL isFusion;
@property (nonatomic) BOOL isRemote;
@property (nonatomic) BOOL isDeviceTypeSet;
@property (nonatomic) BOOL isToggleRelayTimeout;
@property (nonatomic) BOOL isToggleRelayResponseError;

@property (nonatomic, strong) CommonNetworkRoutines *commonNetworkRoutines;

@property (nonatomic, strong) NSMutableData *relayStatusResponseData;

@property (nonatomic, strong) NSMutableData *toggleRelayResponseData;
@property (nonatomic, strong) NSMutableData *momentaryRelayResponseData;
@property (nonatomic, strong) NSMutableData *inputStatusResponseData;
@property (nonatomic, strong) NSMutableData *macroResponseData;

@property (nonatomic, strong) NSTimer *relayTimer;

@property (nonatomic, strong) NSDictionary *remoteDeviceInfo;

+ (TCPCommunications *)sharedInstance;

- (NSString *)getNetworkSSID;
- (void)verifyNetworkConnectivityToDevice:(Device *)device;
- (void)verifySignalSwitchConnectivityToDevice:(Device *)device;

- (void)saveMOC:(NSManagedObjectContext *)context;

- (void)writeDataToSocket:(NSData *)data withTag:(int)tag;

- (void)disconnectSockets;

@end
