//
//  CommonNetworkRoutines.m
//  IORelay
//
//  Created by John Radcliffe on 10/22/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "CommonNetworkRoutines.h"

@implementation CommonNetworkRoutines

# pragma mark - Get current SSID
- (NSString *)getNetworkSSID {
    
    // get current network ssid
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    NSDictionary *myDictionary = (__bridge_transfer NSDictionary*)myDict;
    return [myDictionary objectForKey:@"SSID"];

    
}


# pragma mark - configure API message
// this takes an array of the commands to execute / wraps the commands in the api format / and returns a NSData object representing the command api packet
- (NSData *)buildAPIPacket:(NSArray *)commands {
    
    // build checksum and byte array of commands
    // add first two commands for checksum calc
    unsigned int totalCommandValues = 170 + [commands count];
    
    // initialize byte array of commands
    int commandTotal = [commands count] +3;
    unsigned char bytes[commandTotal];
    // setup first two commands
    bytes[0] = 170; // constant
    bytes[1] = (unsigned int)[commands count]; // number of commands included
    
    // loop through commands that were passed in and add to checksum calc value and add to byte array
    for (int i = 0 ; i < [commands count]; i++) {
        NSNumber *num = [commands objectAtIndex:i];
        unsigned int j = [num intValue];
        // add command value for checksum calc
        totalCommandValues = totalCommandValues + j;
        // add command to byte array
        bytes[i+2] = j;
    }
    // calculate checksum
    unsigned int checkSum = totalCommandValues & (unsigned int)255;
    
    // add checksum to end of byte array
    bytes[(commandTotal-1)] = checkSum;
    
    // convert to NSData
    NSData *data = [NSData dataWithBytes:bytes length:commandTotal];
    
    return data;
}

- (int)convertDataRangeToInt:(NSData *)data {
    
    unsigned char *n = (unsigned char *)[data bytes];
    return *(int *)n;
    
    
}

- (NSString *)convertDataRangeToString:(NSData *)data {
    
    unsigned char *s = (unsigned char *)[data bytes];
    
    NSUInteger sBytes = [data length];
    
    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:sBytes];
    
    for(NSUInteger i=0; i<sBytes; i++ ) {
        [hex appendFormat:@"%02X", s[i]];
        
    }
    return hex;
}




@end
