//
//  Relay.h
//  IORelay
//
//  Created by John Radcliffe on 9/25/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Relay : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * momentary;
@property (nonatomic, retain) Device *device;

@end
