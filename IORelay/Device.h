//
//  Device.h
//  IORelay
//
//  Created by John Radcliffe on 10/31/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Input, Macro, Relay;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * accessPin;
@property (nonatomic, retain) NSNumber * accessSwitch;
@property (nonatomic, retain) NSNumber * accessUnlocked;
@property (nonatomic, retain) NSString * configPin;
@property (nonatomic, retain) NSNumber * configSwitch;
@property (nonatomic, retain) NSNumber * configurationUnlocked;
@property (nonatomic, retain) NSNumber * displayInputs;
@property (nonatomic, retain) NSNumber * displayMacros;
@property (nonatomic, retain) NSNumber * displayRelays;
@property (nonatomic, retain) NSString * ipAddress;
@property (nonatomic, retain) NSString * macAddress;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * networkSSID;
@property (nonatomic, retain) NSNumber * numberOfRelays;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *inputs;
@property (nonatomic, retain) NSSet *macros;
@property (nonatomic, retain) NSSet *relays;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addInputsObject:(Input *)value;
- (void)removeInputsObject:(Input *)value;
- (void)addInputs:(NSSet *)values;
- (void)removeInputs:(NSSet *)values;

- (void)addMacrosObject:(Macro *)value;
- (void)removeMacrosObject:(Macro *)value;
- (void)addMacros:(NSSet *)values;
- (void)removeMacros:(NSSet *)values;

- (void)addRelaysObject:(Relay *)value;
- (void)removeRelaysObject:(Relay *)value;
- (void)addRelays:(NSSet *)values;
- (void)removeRelays:(NSSet *)values;

@end
