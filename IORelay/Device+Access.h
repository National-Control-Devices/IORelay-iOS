//
//  Device+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/10/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Device.h"

@interface Device (Access)

+ (Device *)createDeviceFrom:(NSDictionary *)deviceDictionary InContext:(NSManagedObjectContext *)context;

+ (void)deleteDevice:(Device *)device inContext:(NSManagedObjectContext *)context;

+ (void)updateSecuritySettings:(NSDictionary *)securityInfo forDevice:(Device *)device;

+ (void)accessUnlocked:(Device *)device unlocked:(NSNumber *)unlocked;

+ (void)configurationUnlocked:(Device *)device unlocked:(NSNumber *)unlocked;

+ (void)displayInputsFor:(Device *)device display:(NSNumber *)display;

+ (void)displayRelaysFor:(Device *)device display:(NSNumber *)display;

+ (void)updateNumberOfRelaysFor:(Device *)device number:(NSNumber *)number;

+ (void)displayMacrosFor:(Device *)device display:(NSNumber *)display;

+ (Device *)updateInfoForDevice:(Device *)device InContext:(NSManagedObjectContext *)context;



@end
