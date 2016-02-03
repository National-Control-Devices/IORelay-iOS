//
//  Input+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/22/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Input+Access.h"
#import "Device.h"

@implementation Input (Access)

// create input for device
+ (void)createInputNumber:(NSNumber *)inputNumber ForDevice:(Device *)device {
    
    Input *input = [NSEntityDescription insertNewObjectForEntityForName:@"Input" inManagedObjectContext:device.managedObjectContext];
    
    input.name = [NSString stringWithFormat:@"Input %d",[inputNumber intValue]];
    input.number = inputNumber;
    // set defualt type to not display
    input.type = @"Do not Display";
    
    [device addInputsObject:input];
    
    // save device to table
    [self saveChangesInContext:device.managedObjectContext];
    
}

// update input
+ (void)updateInput:(Input *)input {
    
    [self saveChangesInContext:input.managedObjectContext];
    
}

// save changes to core data
+ (void)saveChangesInContext:(NSManagedObjectContext *)context {
    //saves the context to disk
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Device Save: Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
}

//+ (Input *)getInputForIndex:(NSNumber *)index {
//    
//    // get the input for the current index?
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Input"];
//    
//    NSPredicate *inputPredicate = [NSPredicate predicateWithFormat:@"number = %d", [index intValue]];
//    
//    [fetchRequest setPredicate:inputPredicate];
//    
//    NSError *error;
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//
//    
//}



@end
