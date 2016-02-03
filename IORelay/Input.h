//
//  Input.h
//  IORelay
//
//  Created by John Radcliffe on 11/19/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Input : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * typeNumber;
@property (nonatomic, retain) Device *device;

@end
