//
//  CalculateInputValue.m
//  IORelay
//
//  Created by John Radcliffe on 11/19/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "CalculateInputValue.h"
#include <math.h>
#import "CommonRoutines.h"

static double vRef = 5.000000;
static double voltsPerStep = 4.926/1024.000000;


@implementation CalculateInputValue

- (id)init {
    self = [super init];
    
    self.temp495LookupTable = @[@96.3, @67.01, @47.17, @33.65, @24.26, @17.7, @13.04, @9.707, @7.293, @5.533, @4.232, @3.265, @2.539, @1.99, @1.571, @1.249,
                                @1.00, @0.8057, @0.6531, @0.5327, @0.4369, @0.3603, @0.2986, @0.2488, @0.2083, @0.1752, @0.1481, @0.1258, @0.1072, @0.09177,
                                @0.07885, @0.068, @0.05886, @0.05112, @0.04454, @0.03893, @0.03417, @0.03009, @0.02654, @0.02348, @0.02083, @0.01853, @0.01653];
    
    self.temps495 = @[@-55, @-50, @-45, @-40, @-35, @-30, @-25, @-20, @-15, @-10, @-5, @0, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @65, @70,
                        @75, @80, @85, @90, @95, @100, @110, @115, @120, @125, @130, @135, @140, @145, @150, @155];
    
    self.temp317LookupTable = @[@111000.3, @86000.39, @67000.74, @53000.39, @42000.45, @33000.89, @27000.28, @22000.05, @17000.96, @14000.68, @12000.09, @10000.00,
                                @8000.313, @6000.941, @5000.828, @4000.912, @4000.161, @3000.537, @3000.021, @2000.589, @2000.229, @1000.924, @1000.669, @1000.451,
                                @1000.266, @1000.108, @973.5, @857.4, @757.9];
    
    self.temps317 = @[@-30, @-25, @-20, @-15, @-10, @-5, @0, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @65, @70, @75, @80, @85, @90, @95, @100, @105, @110];
    
    
    
    return self;
}

- (NSNumber *)calcInputValueForType:(NSNumber *)type withDictionary:(NSDictionary *)inputValues {

    int msb = [[inputValues objectForKey:@"msb"] intValue];
    int lsb = [[inputValues objectForKey:@"lsb"] intValue];
    
    switch ([type intValue]) {
        case Raw10bit:
            // process Raw10bit input
            return [self tenBitWithMSB:msb withLSB:lsb];
            break;
            
        case Voltage:
            // process voltage input
            return [self voltage:msb withLSB:lsb];
            break;
        case Resistance:
            // process Resistance input
            return [self resistance:msb withLSB:lsb];
            break;
            
        case Closure:
            // process closure input
            return [self closure:msb withLSB:lsb];
            break;
            
        case Temperature4952171F:
            // process Temp 495-2171F input
            return [self temperature:msb withLSB:lsb forType:@"495" forFarenheitScale:[NSNumber numberWithBool:YES]];
            break;
            
        case Temperature4952171C:
            // process temp 495-2171C input
            return [self temperature:msb withLSB:lsb forType:@"495" forFarenheitScale:[NSNumber numberWithBool:NO]];
            break;
            
        case Temperature3171406F:
            // process temp 317-1406F input
            return [self temperature:msb withLSB:lsb forType:@"317" forFarenheitScale:[NSNumber numberWithBool:YES]];
            break;
            
        case Temperature3171406C:
            // process temp 317-1406C input
            return [self temperature:msb withLSB:lsb forType:@"317" forFarenheitScale:[NSNumber numberWithBool:NO]];
            break;
            
        case Temperature4952172F:
            // process temp 495-2172F input
            return [self temperature:msb withLSB:lsb forType:@"495" forFarenheitScale:[NSNumber numberWithBool:YES]];
            break;
            
        case Temperature4952172C:
            // process temp 495-2172C input
            return [self temperature:msb withLSB:lsb forType:@"495" forFarenheitScale:[NSNumber numberWithBool:NO]];
            break;
            
        case LightLevelPDV8001Lux:
            // process light level pdv800 lux input
            return [self pdvp8001:msb withLSB:lsb];
            break;
            
        case CurrentH722Amps:
            // process current h722 amps input
            return [self currentH722:msb withLSB:lsb];
            break;
            
        case CurrentH822Amps:
            // process current h822 amps input
            return [self currentH822:msb withLSB:lsb];
            break;
            
        case PSI0100Sensor:
            // process psi 0-100 input
            return [self oneHundredPSIPressure:msb withLSB:lsb];
            break;
            
        case PSI0300Sensor:
            // process psi 0-300 input
            return [self threeHundredPSIPressure:msb withLSB:lsb];
            break;
            
        case PX3224:
            // process px3224 input
            return [self px3224:msb withLSB:lsb];
            break;
            
        case PA6229:
            // process pa6229 input
            return [self pa6229:msb withLSB:lsb];
            break;
            
        default:
            break;
    }
    
    return [NSNumber numberWithInt:0];
    
}


// calculate the raw input value
- (NSNumber *)tenBitWithMSB:(int)msb withLSB:(int)lsb {
    
    return [NSNumber numberWithInt:((msb *256) + lsb)];
    
}

// calculate voltage
- (NSNumber *)voltage:(int)msb withLSB:(int)lsb {
    
    int tenbit = [[self tenBitWithMSB:msb withLSB:lsb] intValue];
    double voltsPerStep = vRef/1024.000000;
    double voltage = voltsPerStep * tenbit;
    
    return [NSNumber numberWithDouble:voltage];
    
}

// calculate resistance
- (NSNumber *)resistance:(int)msb withLSB:(int)lsb {
    
    double voltage = [[self voltage:msb withLSB:lsb] doubleValue];
    double value = (10000*(voltage/5)) / (1-(voltage/5));
    
    return [NSNumber numberWithDouble:value];
    
}

// calculate closure
- (NSNumber *)closure:(int)msb withLSB:(int)lsb {
    
    int value = [[self tenBitWithMSB:msb withLSB:lsb] intValue];
    if (value < 512) {
        return [NSNumber numberWithBool:NO]; // closed
    } else {
        return [NSNumber numberWithBool:YES]; // open
    }
    
}

// calculate resistance
- (NSNumber *)temperature:(int)msb withLSB:(int)lsb forType:(NSString *)tempType forFarenheitScale:(NSNumber *)isFarenheit {
    
    // initialize generic arrays for temps
    NSArray *tempLookupTable;
    NSArray *temps;
    
    // if temperature 495
    if ([tempType isEqualToString:@"495"]) {
        tempLookupTable = [NSArray arrayWithArray:self.temp495LookupTable];
        temps = [NSArray arrayWithArray:self.temps495];
    
        // temperature 317
    } else if ([tempType isEqualToString:@"317"]) {
        tempLookupTable = [NSArray arrayWithArray:self.temp317LookupTable];
        temps = [NSArray arrayWithArray:self.temps317];

    }
    
    double lookupValue = ([[self resistance:msb withLSB:lsb] doubleValue] / 10000);
    
    int lookupTablePosition = 0;
    int lowtemp = 0;
    
    for (int i = 0; i < [tempLookupTable count]; i++) {
        if (lookupValue > [[tempLookupTable objectAtIndex:i] doubleValue]) {
            lookupTablePosition = i;
            break;
        }
    }
    
    double tableLowValue = [[tempLookupTable objectAtIndex:lookupTablePosition] doubleValue];
    double tableHighValue = 0;
    
    if (lookupTablePosition > 0) {
        lowtemp = [[temps objectAtIndex:(lookupTablePosition -1)] intValue];
        tableHighValue = [[tempLookupTable objectAtIndex:(lookupTablePosition -1)] doubleValue];
    }
    
    double difference = tableHighValue - tableLowValue;
    double stepValue = difference / 5;
    double remainder = lookupValue - tableLowValue;
    double tempDifference = (difference - remainder) / stepValue;
    
    int temperature = (int)(lowtemp + tempDifference);
    
    if ([isFarenheit boolValue]) {
        return [NSNumber numberWithInt:((temperature * 9/5) +32)];
    } else {
        return [NSNumber numberWithInt:temperature];
    }
    
    
}

// calculate closure
- (NSNumber *)pdvp8001:(int)msb withLSB:(int)lsb {
    
    double resistance = [[self resistance:msb withLSB:lsb] doubleValue];
    
    int lux = (int)(3777479.31 * pow(resistance, -1.3));
    
    return [NSNumber numberWithInt:lux];
}

// calculate closure
- (NSNumber *)currentH722:(int)msb withLSB:(int)lsb {
    
    int reading = [[self tenBitWithMSB:msb withLSB:lsb] intValue];
    
    double currentPerStep = (60.000000/1024.000000);
    double current = reading * currentPerStep;
    return [NSNumber numberWithDouble:current];
    
}

- (NSNumber *)currentH822:(int)msb withLSB:(int)lsb {
    
    double inputVoltage = [[self voltage:msb withLSB:lsb] doubleValue];
    
    int steps = (int)(inputVoltage/voltsPerStep);
    
    double currentPerStep = (10.000000/1024.000000);
    double current = steps * currentPerStep;
    
    return [NSNumber numberWithDouble:current];
    
}

- (NSNumber *)oneHundredPSIPressure:(int)msb withLSB:(int)lsb {
    
    double inputVoltage = [[self voltage:msb withLSB:lsb] doubleValue];
    
    int steps = (int)(inputVoltage/voltsPerStep);
    
    double psiPerStep = (100.000000/1024.000000);
    
    int psi = (int)(steps * psiPerStep);
    
    return [NSNumber numberWithInt:psi];
    
}

- (NSNumber *)threeHundredPSIPressure:(int)msb withLSB:(int)lsb {
    
    double inputVoltage = [[self voltage:msb withLSB:lsb] doubleValue];
    
    int steps = (int)(inputVoltage/voltsPerStep);
    
    double psiPerStep = (300.000000/1024);
    
    int psi = (int)(steps * psiPerStep);
    
    return [NSNumber numberWithInt:psi];
}


- (NSNumber *)px3224:(int)msb withLSB:(int)lsb {
    double inputVoltage = [[self voltage:msb withLSB:lsb] doubleValue];
    
    //voltsPerStep = 0.0048105
    int steps = (int)((inputVoltage/voltsPerStep)-207);		//2.878598
    
    double psiPerStep = (100.000000/819.000000);		//0.1221001
    
    int psi = (int)(steps * psiPerStep);
    
    return [NSNumber numberWithInt:psi];
}

- (NSNumber *)pa6229:(int)msb withLSB:(int)lsb {
    int reading = ([[self tenBitWithMSB:msb withLSB:lsb] intValue] - 204);
    double barsPerStep = 1/819.2;			//0.001221001221
    
    return [NSNumber numberWithDouble:(reading * barsPerStep)];
    
}


@end
