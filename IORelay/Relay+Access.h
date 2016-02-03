//
//  Relay+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/25/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Relay.h"

@interface Relay (Access)

+ (void)createRelayNumber:(NSNumber *)inputNumber ForDevice:(Device *)device;
+ (void)deleteRelay:(Relay *)relay;
+ (void)updateRelay:(Relay *)relay;

@end
