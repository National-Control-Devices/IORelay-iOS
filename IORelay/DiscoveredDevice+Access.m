//
//  DiscoveredDevice+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "DiscoveredDevice+Access.h"
#import "Device+Access.h"

@implementation DiscoveredDevice (Access)

// create a new detected device
+ (void)createDeviceFrom:(NSDictionary *)deviceInfo InContext:(NSManagedObjectContext *)context {
    
    // does this entry already exist in the discovered device table?
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DiscoveredDevice"];
    
    NSPredicate *devicePredicate = [NSPredicate predicateWithFormat:@"macAddress = %@", [deviceInfo objectForKey:@"macAddress"]];
    
    [fetchRequest setPredicate:devicePredicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    // not found if zero objects in our array
    if ([fetchedObjects count] == 0) {
        
        // does this entry already exist in the device table?
        fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Device"];
        
        [fetchRequest setPredicate:devicePredicate];
        
        fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        // not found if zero objects in our array
        if ([fetchedObjects count] == 0) {
            
            // create a new discovered device entity
            DiscoveredDevice *device = [NSEntityDescription insertNewObjectForEntityForName:@"DiscoveredDevice" inManagedObjectContext:context];
            
            device.name = [deviceInfo objectForKey:@"name"];
            device.macAddress = [deviceInfo objectForKey:@"macAddress"];
            device.ipAddress = [deviceInfo objectForKey:@"ipAddress"];
            device.networkSSID = [deviceInfo objectForKey:@"networkSSID"];
            device.port = [deviceInfo objectForKey:@"port"];
            device.signalStrength = [deviceInfo objectForKey:@"signalStrength"];
            device.type = [deviceInfo objectForKey:@"type"];

            [self saveChangesInContext:context];
            
        // we found this in the device list - so update it's info
        } else {
            
            [Device createDeviceFrom:deviceInfo InContext:context];
            
        }
        
    // we found this device in the discovered device list - so update it's info
    } else {
        
        DiscoveredDevice *device = [fetchedObjects firstObject];
        
        device.ipAddress = [deviceInfo objectForKey:@"ipAddress"];
        device.networkSSID = [deviceInfo objectForKey:@"networkSSID"];
        device.port = [deviceInfo objectForKey:@"port"];
        device.signalStrength = [deviceInfo objectForKey:@"signalStrength"];
        
        [self saveChangesInContext:context];

        
    }

    
}


// delete discovered device
+ (void)deleteDevice:(DiscoveredDevice *)device inContext:(NSManagedObjectContext *)context {
    
    [context deleteObject:device];
    
    [self saveChangesInContext:context];
    
}

// clear all previously discovered devices
+ (void)deleteAllDiscoveredDevicesInContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"DiscoveredDevice"];
    
    NSError *error;
    NSArray *discoveredDevices = [context executeFetchRequest:request error:&error];
    
    for (DiscoveredDevice *device in discoveredDevices) {
        [context deleteObject:device];
        [self saveChangesInContext:context];
    }
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
