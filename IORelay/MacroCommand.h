//
//  MacroCommand.h
//  IORelay
//
//  Created by John Radcliffe on 10/2/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Macro;

@interface MacroCommand : NSManagedObject

@property (nonatomic, retain) NSString * commands;
@property (nonatomic, retain) NSNumber * delay;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Macro *macro;

@end
