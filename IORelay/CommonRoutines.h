//
//  CommonRoutines.h
//  IORelay
//
//  Created by John Radcliffe on 10/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// WARNING: this enum is tied to the order that these input types are created in InputTypeKeywords+Access
typedef enum {
    DoNotDisplay,
    Raw10bit,
    Voltage,
    Resistance,
    Closure,
    Temperature4952171F,
    Temperature4952171C,
    Temperature3171406F,
    Temperature3171406C,
    Temperature4952172F,
    Temperature4952172C,
    LightLevelPDV8001Lux,
    CurrentH722Amps,
    CurrentH822Amps,
    PSI0100Sensor,
    PSI0300Sensor,
    PX3224,
    PA6229,
} InputType;


@interface CommonRoutines : NSObject

- (void)processErrorMessage:(NSNotification *)notification;

+ (CommonRoutines *)sharedInstance;

- (NSString *)formatMacAddress:(NSString *)macAddress;
- (NSString *)unformatMacAddress:(NSString *)macAddress;
- (NSString *)convertWiFiSignalStrength:(NSString *)signal;


- (void)vibrateMe;

@end
