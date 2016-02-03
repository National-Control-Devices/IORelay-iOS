//
//  InputTypeKeywords+Access.m
//  IORelay
//
//  Created by John Radcliffe on 9/24/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputTypeKeywords+Access.h"

@implementation InputTypeKeywords (Access)

// create keywords - this is temporary until I incorporate csv imports with other data

+ (void)createInitialInputKeywordsInContext:(NSManagedObjectContext *)context {
    
// WARNING: this array order is tied to an enum in CalculateInputValue
    // array of types
    NSArray *inputTypesArray = @[@"Do Not Display",
                                 @"Raw 10 bit",
                                 @"Voltage",
                                 @"Resistance",
                                 @"Closure",
                                 @"Temperature(495-2171)F",
                                 @"Temperature(495-2171)C",
                                 @"Temperature(317-1406)F",
                                 @"Temperature(317-1406)C",
                                 @"Temperature(495-2172)F",
                                 @"Temperature(495-2172)C",
                                 @"Light Level(PDV-8001)Lux",
                                 @"Current(H722)Amps",
                                 @"Current(H822)Amps",
                                 @"0-100 PSI Sensor",
                                 @"0-300 PSI Sensor",
                                 @"PX3224",
                                 @"PA6229"];
    
    // create core data records
    InputTypeKeywords *keyword;
    
    for (int i = 0 ; i < [inputTypesArray count]; i++) {
        keyword = [NSEntityDescription insertNewObjectForEntityForName:@"InputTypeKeywords" inManagedObjectContext:context];
        keyword.name = [inputTypesArray objectAtIndex:i];
        keyword.number = [NSNumber numberWithInt:i];
    }
    
    // save keywords to core data
    
    [self saveChangesInContext:context];
    
}

// get all keywords
+ (NSArray *)getTypeKeywordsInContext:(NSManagedObjectContext *)context {
    
    // fetch all input types sorted by number - or the order you see in the method above
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"InputTypeKeywords"];
    
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    return [context executeFetchRequest:fetchRequest error:&error];

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
