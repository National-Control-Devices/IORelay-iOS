//
//  MacroControl.m
//  IORelay
//
//  Created by John Radcliffe on 11/13/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "MacroControl.h"
#import "MacroCommand.h"
#import "TCPCommunications.h"

static MacroControl *_sharedInstance;

@implementation MacroControl

# pragma mark - Object Lifecycle
+ (MacroControl *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MacroControl alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    self.commonNetworkRoutines = [[CommonNetworkRoutines alloc] init];
        
    return self;
}

// perform commands
- (void)performMacroCommands:(NSArray *)commands {
    
    for (int i = 0; i < [commands count]; i++) {
        
        // get the macroCommand
        MacroCommand *command = [commands objectAtIndex:i];
        
        [self performSelector:@selector(performCommand:) withObject:command afterDelay:[self convertToMilliseconds:command.delay]];
        
//        usleep([self convertToMilliseconds:command.delay]);
      

    }
    
    [[CommonRoutines sharedInstance] vibrateMe];
    
}

- (void)performCommand:(MacroCommand *)command {
    
    // load string of commands into array
    NSArray *commandArray = [command.commands componentsSeparatedByString:@","];
    
    NSData *data = [self.commonNetworkRoutines buildAPIPacket:commandArray];
    [[TCPCommunications sharedInstance] writeDataToSocket:data withTag:[command.event isEqualToString:@"TouchDown"]? ProcessTouchDownCommands : ProcessTouchUpCommands];
    
}

// Convert delay to milliseconds
- (CGFloat)convertToMilliseconds:(NSNumber *)delay {
    
    CGFloat milli = ([delay intValue] * .001);
    
    return milli;
}



@end
