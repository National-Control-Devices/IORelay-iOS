//
//  Macro+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Macro.h"

@interface Macro (Access)

+ (Macro *)createMacroFrom:(NSDictionary *)macroInfo forDevice:(Device *)device;

+ (NSNumber *)getLastMacroNumberInContext:(NSManagedObjectContext *)context;

+ (void)deleteMacro:(Macro *)macro inContext:(NSManagedObjectContext *)context;

@end
