//
//  MacroControl.h
//  IORelay
//
//  Created by John Radcliffe on 11/13/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkRoutines.h"
#import "CommonRoutines.h"


@interface MacroControl : NSObject

@property (nonatomic, strong) CommonNetworkRoutines *commonNetworkRoutines;

+ (MacroControl *)sharedInstance;

- (void)performMacroCommands:(NSArray *)commands;

@end
