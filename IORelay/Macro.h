//
//  Macro.h
//  IORelay
//
//  Created by John Radcliffe on 9/29/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device, MacroCommand;

@interface Macro : NSManagedObject

@property (nonatomic, retain) NSString * macroDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSSet *commands;
@property (nonatomic, retain) Device *device;
@end

@interface Macro (CoreDataGeneratedAccessors)

- (void)addCommandsObject:(MacroCommand *)value;
- (void)removeCommandsObject:(MacroCommand *)value;
- (void)addCommands:(NSSet *)values;
- (void)removeCommands:(NSSet *)values;

@end
