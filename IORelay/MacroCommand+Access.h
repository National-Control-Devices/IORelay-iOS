//
//  MacroCommand+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/29/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroCommand.h"

@interface MacroCommand (Access)

+ (void)createMacroCommandFrom:(NSDictionary *)commandInfo forMacro:(Macro *)macro;

+ (NSNumber *)getLastCommandNumberForMacro:(Macro *)macro InContext:(NSManagedObjectContext *)context;

+ (void)deleteMacroCommand:(MacroCommand *)command inContext:(NSManagedObjectContext *)context;

@end
