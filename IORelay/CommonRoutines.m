//
//  CommonRoutines.m
//  IORelay
//
//  Created by John Radcliffe on 10/26/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "CommonRoutines.h"

static CommonRoutines *_sharedInstance;


@implementation CommonRoutines

# pragma mark - Object Lifecycle
+ (CommonRoutines *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[CommonRoutines alloc] init];
        
    });
    
    return _sharedInstance;
}

- (id)init {
    
    self = [super init];
    
    // listen for error messages
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processErrorMessage:) name:@"ShowAlert" object:nil];
    
    return self;
}

- (void)processErrorMessage:(NSNotification *)notification {
    
    NSLog(@"process error");
    NSString *title = [[notification userInfo] valueForKey:@"title"];
    NSString *message = [[notification userInfo] valueForKey:@"error"];
    
    [self showAlert:title message:message];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    NSLog(@"show alert");
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
}


- (NSString *)formatMacAddress:(NSString *)macAddress {
    
    if (macAddress == nil) {
        return @"";
    }
    
    NSString *formattedMacAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",
                                     [macAddress substringToIndex:2],
                                     [macAddress substringWithRange:NSMakeRange(2, 2)],
                                     [macAddress substringWithRange:NSMakeRange(4, 2)],
                                     [macAddress substringWithRange:NSMakeRange(6, 2)],
                                     [macAddress substringWithRange:NSMakeRange(8, 2)],
                                     [macAddress substringFromIndex:[macAddress length]-2]];
    
//    // if we don't have a valid mac address return blank
//    if ([formattedMacAddress containsString:@"null"]) {
//        formattedMacAddress = @"";
//    }
    
    return formattedMacAddress;
}

- (NSString *)unformatMacAddress:(NSString *)macAddress {  // 00:00:00:00:00:00
                                                           //
    if (macAddress == nil) {
        return @"";
    }
    
    NSString *formattedMacAddress = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                                     [macAddress substringToIndex:2],
                                     [macAddress substringWithRange:NSMakeRange(3, 2)],
                                     [macAddress substringWithRange:NSMakeRange(6, 2)],
                                     [macAddress substringWithRange:NSMakeRange(9, 2)],
                                     [macAddress substringWithRange:NSMakeRange(12, 2)],
                                     [macAddress substringFromIndex:[macAddress length]-2]];
    
//    // if we don't have a valid mac address return blank
//    if ([formattedMacAddress containsString:@"null"]) {
//        formattedMacAddress = @"";
//    }
    
    return formattedMacAddress;
}


- (void)vibrateMe {
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

- (NSString *)convertWiFiSignalStrength:(NSString *)signal {
    
    NSString *signalStrength;
    
    if ([signal intValue] > 74) {
        signalStrength = [NSString stringWithFormat:@"Signal Strength - (%@) %@", signal, @"Weak"];
    } else if ([signal intValue] <= 74 && [signal intValue] >= 64) {
        signalStrength = [NSString stringWithFormat:@"Signal Strength - (%@) %@", signal, @"Fair"];
    } else if ([signal intValue] < 64 && [signal intValue] >= 53) {
        signalStrength = [NSString stringWithFormat:@"Signal Strength - (%@) %@", signal, @"Good"];
    } else if ([signal intValue] < 53 && [signal intValue] >= 42) {
        signalStrength = [NSString stringWithFormat:@"Signal Strength - (%@) %@", signal, @"Very Good"];
    } else {
        signalStrength = [NSString stringWithFormat:@"Signal Strength - (%@) %@", signal, @"Excellent"];
    }
    
    return signalStrength;
}



@end
