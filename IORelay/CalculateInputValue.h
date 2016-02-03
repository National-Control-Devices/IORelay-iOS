//
//  CalculateInputValue.h
//  IORelay
//
//  Created by John Radcliffe on 11/19/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateInputValue : NSObject

@property (nonatomic, strong) NSArray *temp495LookupTable;
@property (nonatomic, strong) NSArray *temps495;
@property (nonatomic, strong) NSArray *temp317LookupTable;
@property (nonatomic, strong) NSArray *temps317;


- (NSNumber *)tenBitWithMSB:(int)msb withLSB:(int)lsb;
- (NSNumber *)voltage:(int)msb withLSB:(int)lsb;
- (NSNumber *)resistance:(int)msb withLSB:(int)lsb;
- (NSNumber *)calcInputValueForType:(NSNumber *)type withDictionary:(NSDictionary *)inputValues;

@end
