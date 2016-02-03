//
//  DiscoveredDevice+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "DiscoveredDevice.h"

@interface DiscoveredDevice (Access)

+ (void)createDeviceFrom:(NSDictionary *)deviceDictionary InContext:(NSManagedObjectContext *)context;

+ (void)deleteDevice:(DiscoveredDevice *)device inContext:(NSManagedObjectContext *)context;

+ (void)deleteAllDiscoveredDevicesInContext:(NSManagedObjectContext *)context;


@end
