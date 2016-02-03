//
//  Macro+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Macro+Access.h"
#import "Device.h"

@implementation Macro (Access)

// create / update macro
+ (Macro *)createMacroFrom:(NSDictionary *)macroInfo forDevice:(Device *)device {
    
    // does this entry already exist?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Macro"];
    
    NSPredicate *macroPredicate = [NSPredicate predicateWithFormat:@"number = %d",[[macroInfo objectForKey:@"number"] intValue]];
    
    [fetchRequest setPredicate:macroPredicate];
    
    Macro *macro;
    
    NSError *error;
    NSArray *fetchedObjects = [device.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] == 0) {
        macro = [NSEntityDescription insertNewObjectForEntityForName:@"Macro" inManagedObjectContext:device.managedObjectContext];
        macro.number = [macroInfo objectForKey:@"number"];
        [device addMacrosObject:macro];

    } else {
        macro = [fetchedObjects lastObject];
    }

    macro.name = [macroInfo objectForKey:@"name"];
    
    // save device to table
    [self saveChangesInContext:device.managedObjectContext];
    
    return macro;
    
}

// return the last sequential macro number
+ (NSNumber *)getLastMacroNumberInContext:(NSManagedObjectContext *)context {
    
    // does this entry already exist?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Macro"];

    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    Macro *lastMacro = [fetchedObjects lastObject];
    
    return lastMacro.number;
    
    
}

// delete macro
+ (void)deleteMacro:(Macro *)macro inContext:(NSManagedObjectContext *)context {
    
    [context deleteObject:macro];
    
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
