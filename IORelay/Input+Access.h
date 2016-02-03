//
//  Input+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/22/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "Input.h"

@interface Input (Access)

+ (void)createInputNumber:(NSNumber *)inputNumber ForDevice:(Device *)device;
+ (void)updateInput:(Input *)input;
@end
