//
//  Device+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Device+Access.h"

@implementation Device (Access)

// create or update device
+ (Device *)createDeviceFrom:(NSDictionary *)deviceInfo InContext:(NSManagedObjectContext *)context {
    
    // does this entry already exist?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Device"];
    
    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"macAddress = %@", [deviceInfo objectForKey:@"macAddress"]];
    
    [fetchRequest setPredicate:devicePredicate];
    
    Device *device;
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] == 0) {
        // create a new device entity
        device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:context];
        device.accessSwitch = [NSNumber numberWithBool:NO];
        device.configSwitch = [NSNumber numberWithBool:NO];
        device.accessUnlocked = [NSNumber numberWithBool:NO];
        device.configurationUnlocked = [NSNumber numberWithBool:NO];
        device.displayInputs = [NSNumber numberWithBool:NO];
        device.displayRelays = [NSNumber numberWithBool:NO];
        device.numberOfRelays = [NSNumber numberWithInt:1];
        

    } else {
        // else get object found in device table
        device = [fetchedObjects lastObject];
    }

    // load info for this device
    // do not replace device name if we are refreshing info from discovery - it would come from updcommunications with New xxxx Device as name. 
    NSString *deviceName = [deviceInfo objectForKey:@"name"];
    
    if (device.name == nil) {
        device.name = deviceName;
    } else {
        
        if (![deviceName containsString:@"New"]) {
            device.name = deviceName;
        }
    }
    
    device.macAddress = [deviceInfo objectForKey:@"macAddress"];
    device.ipAddress = [deviceInfo objectForKey:@"ipAddress"];
    device.networkSSID = [deviceInfo objectForKey:@"networkSSID"];
    device.port = [NSNumber numberWithInt:[[deviceInfo objectForKey:@"port"] intValue]];
    device.type = [deviceInfo objectForKey:@"type"];
    
    // save device to table
    [self saveChangesInContext:context];
    
    return device;
    
}

// create or update device
+ (Device *)updateInfoForDevice:(Device *)device InContext:(NSManagedObjectContext *)context {
    
    // does this entry already exist?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Device"];
    
    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"macAddress = %@", device.macAddress];
    
    [fetchRequest setPredicate:devicePredicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
       device = [fetchedObjects lastObject];
    }
    
    return device;
    
}


// lock / unlock access
+ (void)accessUnlocked:(Device *)device unlocked:(NSNumber *)unlocked {
    
    device.accessUnlocked = unlocked;
    
    [self saveChangesInContext:device.managedObjectContext];

}

// lock / unlock configuration
+ (void)configurationUnlocked:(Device *)device unlocked:(NSNumber *)unlocked {
    
    device.configurationUnlocked = unlocked;
    
    [self saveChangesInContext:device.managedObjectContext];
    
}

// device control will display inputs information
+ (void)displayInputsFor:(Device *)device display:(NSNumber *)display {
    
    device.displayInputs = display;
    
    [self saveChangesInContext:device.managedObjectContext];
    
}

// device control will display relay information
+ (void)displayRelaysFor:(Device *)device display:(NSNumber *)display {
    
    device.displayRelays = display;
    
    [self saveChangesInContext:device.managedObjectContext];
    
}

// device control will display macro information
+ (void)displayMacrosFor:(Device *)device display:(NSNumber *)display {
    
    device.displayMacros = display;
    
    [self saveChangesInContext:device.managedObjectContext];
    
}

// update the number of relays to display
+ (void)updateNumberOfRelaysFor:(Device *)device number:(NSNumber *)number {
    
    device.numberOfRelays = number;
    
    [self saveChangesInContext:device.managedObjectContext];
    
}

// update security information access/pin configuration/pin
+ (void)updateSecuritySettings:(NSDictionary *)securityInfo forDevice:(Device *)device {
    
    device.accessSwitch = [securityInfo objectForKey:@"accessSwitch"];
    device.accessPin = [securityInfo objectForKey:@"accessPin"];
    device.configSwitch = [securityInfo objectForKey:@"configSwitch"];
    device.configPin = [securityInfo objectForKey:@"configPin"];
    
    [self saveChangesInContext:device.managedObjectContext];
}

// delete device
+ (void)deleteDevice:(Device *)device inContext:(NSManagedObjectContext *)context {
    
    [context deleteObject:device];
    
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
