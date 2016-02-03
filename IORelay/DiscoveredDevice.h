//
//  DiscoveredDevice.h
//  IORelay
//
//  Created by John Radcliffe on 10/31/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DiscoveredDevice : NSManagedObject

@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * macAddress;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * networkSSID;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * signalStrength;
@property (nonatomic, retain) NSString * type;

@end
