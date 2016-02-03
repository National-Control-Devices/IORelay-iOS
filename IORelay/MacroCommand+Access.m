//
//  MacroCommand+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/29/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroCommand+Access.h"
#import "Macro.h"

@implementation MacroCommand (Access)

// create update macro command
+ (void)createMacroCommandFrom:(NSDictionary *)commandInfo forMacro:(Macro *)macro {
    
    // does this entry already exist?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"MacroCommand"];
    
    NSPredicate *commandPredicate = [NSPredicate predicateWithFormat:@"macro = %@ && number = %@", macro, [commandInfo objectForKey:@"number"]];
    
    [fetchRequest setPredicate:commandPredicate];
    
    MacroCommand *macroCommand;
    
    NSError *error;
    NSArray *fetchedObjects = [macro.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] == 0) {
        macroCommand = [NSEntityDescription insertNewObjectForEntityForName:@"MacroCommand" inManagedObjectContext:macro.managedObjectContext];
        macroCommand.number = [commandInfo objectForKey:@"number"];
        macroCommand.event = [commandInfo objectForKey:@"type"];

        [macro addCommandsObject:macroCommand];
        
    } else {
        
        macroCommand = [fetchedObjects lastObject];
    }
    
    macroCommand.delay = [NSNumber numberWithInt:[(NSString *)[commandInfo objectForKey:@"delay"] intValue] ];
    macroCommand.commands = [commandInfo objectForKey:@"commands"];

    
    // save device to table
    [self saveChangesInContext:macro.managedObjectContext];
    
}

// get last macro command sequential number
+ (NSNumber *)getLastCommandNumberForMacro:(Macro *)macro InContext:(NSManagedObjectContext *)context {
    
    NSArray *commands = [macro.commands allObjects];
    
    // sort commands by number
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    NSArray *sortedCommands = [commands sortedArrayUsingDescriptors:sortDescriptors];
    
    MacroCommand *lastCommand = [sortedCommands lastObject];

    return lastCommand.number;
    
    
}

// delete macro command
+ (void)deleteMacroCommand:(MacroCommand *)command inContext:(NSManagedObjectContext *)context {
    
    [context deleteObject:command];
    
    [self saveChangesInContext:context];
    
}

// save to core data
+ (void)saveChangesInContext:(NSManagedObjectContext *)context {
    //saves the context to disk
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Device Save: Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
}



@end
