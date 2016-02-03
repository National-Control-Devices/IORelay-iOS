//
//  Relay+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/25/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Relay+Access.h"
#import "Device.h"

@implementation Relay (Access)

// create relay
+ (void)createRelayNumber:(NSNumber *)inputNumber ForDevice:(Device *)device {
    
    Relay *relay = [NSEntityDescription insertNewObjectForEntityForName:@"Relay" inManagedObjectContext:device.managedObjectContext];
    
    relay.name = [NSString stringWithFormat:@"Relay %d",[inputNumber intValue]];
    relay.number = inputNumber;
    relay.momentary = [NSNumber numberWithBool:NO];
    
    [device addRelaysObject:relay];
    
    // save info to table
    [self saveChangesInContext:device.managedObjectContext];
    
}

// delete relay
+ (void)deleteRelay:(Relay *)relay {
    
    NSManagedObjectContext *context = relay.managedObjectContext;
    
    [context deleteObject:relay];
    
    [self saveChangesInContext:context];
    
}

// update relay
+ (void)updateRelay:(Relay *)relay {
    
    [self saveChangesInContext:relay.managedObjectContext];
    
    
}

// save changes to core data
+ (void)saveChangesInContext:(NSManagedObjectContext *)context {
    //saves the context to disk
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Device Save: Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
}



@end
