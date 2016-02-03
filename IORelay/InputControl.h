//
//  InputControl.h
//  IORelay
//
//  Created by John Radcliffe on 10/30/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkRoutines.h"

@interface InputControl : NSObject

@property (nonatomic, strong) CommonNetworkRoutines *commonNetworkRoutines;
@property (nonatomic, strong) NSMutableArray *inputStatus;

+ (InputControl *)sharedInstance;

- (void)requestAllInputsStatus;
- (NSArray *)getAllInputsStatus;


@end
