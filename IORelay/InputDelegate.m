//
//  InputDelegate.m
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputDelegate.h"
#import "Input.h"
#import "InputControl.h"
#import "CommonRoutines.h"

static InputDelegate *_sharedInstance;
static int MAXInputValue = 1023;

@implementation InputDelegate

# pragma mark - Object Lifecycle
+ (InputDelegate *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[InputDelegate alloc] init];
        
    });
    
    return _sharedInstance;
}


- (id)init {
    
    self = [super init];
    
    NSString *storyBoardName = @"Main";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyBoardName = [NSString stringWithFormat:@"%@_iPad", storyBoardName];
        
    } else {
        storyBoardName = [NSString stringWithFormat:@"%@_iPhone", storyBoardName];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    self.parentViewController = [storyboard instantiateViewControllerWithIdentifier:@"ControlTableViewController"];
    
    self.calculateInputValue = [[CalculateInputValue alloc] init];
    
    return self;
}


- (NSMutableArray *)getInputInfoForDevice:(Device *)device {
    
    // get input status from control
    self.inputStatus = [[InputControl sharedInstance] getAllInputsStatus];

    return [self buildTableSectionsFromArray:[device.inputs allObjects]];
    
}

- (NSMutableArray *)buildTableSectionsFromArray:(NSArray *)inputs {
    
    // sort inputs
     NSArray *sortedInputs = [self sortInputs:inputs];
    
    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [sortedInputs count]; i++) {
        
        Input *input = [sortedInputs objectAtIndex:i];
        
        UITableViewCell *displayCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceControl"];
        [displayCell setSelectionStyle:UITableViewCellSelectionStyleNone];

        UILabel *inputName = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 100, 30)];
        inputName.text = input.name;
        
        [displayCell.contentView addSubview:inputName];
        
        if ([self.inputStatus count] > i) {
            
            // calculate the input value for the type of input selected (raw, temp...)
            int inputStatusIndex = [input.number intValue] -1;
//            NSLog(@"input number = %d", inputStatusIndex);
            NSNumber *inputValue = [self.calculateInputValue calcInputValueForType:input.typeNumber withDictionary:[self.inputStatus objectAtIndex:inputStatusIndex]];
            
            // build display for cell depending on type of input
            switch ([input.typeNumber intValue]) {
                // output progress bar
                case Raw10bit: {
                    
                    UIProgressView *progress = [self createProgressViewWithConstraintsInCell:displayCell];
                    float progressPercent = 0.00;
                    
                    progressPercent = [inputValue floatValue] / MAXInputValue;  // this is for raw value only
                    
                    [progress setProgress:progressPercent];
                    
                    
                }
                
                    break;
                    
                    
                    
                case CurrentH722Amps:
                case CurrentH822Amps: {
                    UILabel *currentLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    currentLabel.text = [NSString stringWithFormat:@"Current: %.4f amps", [inputValue doubleValue]];

                }
                    
                    break;
                    
                case LightLevelPDV8001Lux: {
                    UILabel *luxLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    double luxValue = [inputValue doubleValue]; // * .0001;
                    luxLabel.text = [NSString stringWithFormat:@"Light Level: %.4f lux", luxValue];

                    
                }

                    break;
                    
                case Voltage: {
                    UILabel *voltageLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    double voltageValue = [inputValue doubleValue]; // * .0001;
                    voltageLabel.text = [NSString stringWithFormat:@"Voltage: %.4f vdc", voltageValue];

                    
                }
                 
                    break;
                    
                case Resistance: {
                    UILabel *resistanceLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    double resistanceValue = [inputValue doubleValue]; // * .0001;
                    resistanceLabel.text = [NSString stringWithFormat:@"Resistance: %.4f ohms", resistanceValue];
                    
                }
                    
                    break;
                
                // process closure reading  -  open vs closed
                case Closure: {
                    
                    UILabel *closureLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                
                    if ([inputValue boolValue]) {
                        // Return open
                        closureLabel.text = @"Open";
                    } else {
                        // return closed
                        closureLabel.text = @"Closed";

                    }
                    
                }
                
                    break;
               
                
                // process temperature
                case Temperature4952171F:
                case Temperature3171406F:
                case Temperature4952172F: {
                    
                    UILabel *tempLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    tempLabel.text = [NSString stringWithFormat:@"Temp: %.1f F", [inputValue doubleValue]];
                
                    
                }
            
                    break;
                    
                    // process temperature
                case Temperature4952171C:
                case Temperature3171406C:
                case Temperature4952172C: {
                    
                    UILabel *tempLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    tempLabel.text = [NSString stringWithFormat:@"Temp: %.1f C", [inputValue doubleValue]];
                
   
                }
                    
                    break;
                    
                case PSI0100Sensor:
                case PSI0300Sensor: {
                    
                    UILabel *psiLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    psiLabel.text = [NSString stringWithFormat:@"PSI: %.1f", [inputValue doubleValue]];
                }
                    break;
                    
                case PX3224: {
                    UILabel *pxLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    pxLabel.text = [NSString stringWithFormat:@"PX3224: %.4f", [inputValue doubleValue]];
                }
                    break;
                    
                case PA6229: {
                    UILabel *psiLabel = [self createDetailLabelWithConstraintsInCell:displayCell];
                    psiLabel.text = [NSString stringWithFormat:@"PA6229: %.4f", [inputValue doubleValue]];
                }
                    break;
                    
                default:
                    break;
            }
            

            
        }

        [list addObject:displayCell];
        
        [self.tableSections addObject:list];
        
    }
    

    return self.tableSections;
    
}

// create restraints on progress view
- (UIProgressView *)createProgressViewWithConstraintsInCell:(UITableViewCell *)displayCell {
    
    UIProgressView *progress = [[UIProgressView alloc] init];
    
    // add to cell now so restraints will work
    [displayCell.contentView addSubview:progress];

    // autolayout restraint to use the entire cell width
    // use only restraints specified here
    progress.translatesAutoresizingMaskIntoConstraints = NO;
    // restraint for height
    NSLayoutConstraint *progressHeight = [NSLayoutConstraint constraintWithItem:progress
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:5];
    [progress addConstraint:progressHeight];
    
//    // restraint for top
//    NSLayoutConstraint *progressTop = [NSLayoutConstraint constraintWithItem:progress
//                                                                   attribute:NSLayoutAttributeTop
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:displayCell
//                                                                   attribute:NSLayoutAttributeTop
//                                                                  multiplier:1.0
//                                                                    constant:30];
//    
//    
//    
//    [displayCell addConstraint:progressTop];
    
    // restraint for top
    NSLayoutConstraint *progressBottom = [NSLayoutConstraint constraintWithItem:progress
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:displayCell
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-5];
    
    
    
    [displayCell addConstraint:progressBottom];

    
    // restraint for left padding
    NSLayoutConstraint *progressLeft = [NSLayoutConstraint constraintWithItem:progress
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:displayCell
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:20];
    
    [displayCell addConstraint:progressLeft];
    
    // restraint for right padding
    NSLayoutConstraint *progressRight = [NSLayoutConstraint constraintWithItem:progress
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:displayCell
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:-20];
    
    [displayCell addConstraint:progressRight];
    
    //        progress.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [progress setProgressViewStyle:UIProgressViewStyleBar];

    return progress;
}

// create restraints on detail label view
- (UILabel *)createDetailLabelWithConstraintsInCell:(UITableViewCell *)displayCell {
    
    UILabel *detailLabel = [[UILabel alloc] init];
    
    // add to cell now so restraints will work
    [displayCell.contentView addSubview:detailLabel];
    
    // autolayout restraint to use the entire cell width
    // use only restraints specified here
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // restraint for height
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:30];   //CGRectMake(150, 7, 100, 30)];
    [detailLabel addConstraint:labelHeight];
    
    // restraint for width
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:250];



    [detailLabel addConstraint:labelWidth];
    
    // restraint for bottom
    NSLayoutConstraint *labelBottom = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:displayCell
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:-5];
    
    
    
    [displayCell addConstraint:labelBottom];
    
    
//    // restraint for left padding
//    NSLayoutConstraint *progressLeft = [NSLayoutConstraint constraintWithItem:progress
//                                                                    attribute:NSLayoutAttributeLeading
//                                                                    relatedBy:NSLayoutRelationEqual
//                                                                       toItem:displayCell
//                                                                    attribute:NSLayoutAttributeLeft
//                                                                   multiplier:1.0
//                                                                     constant:20];
//    
//    [displayCell addConstraint:progressLeft];
    
    // restraint for right padding
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:displayCell
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:-20];
    
    [displayCell addConstraint:labelRight];
    
    // since we glue this to the right - allign text to end there
    detailLabel.textAlignment = NSTextAlignmentRight;
    
    return detailLabel;
}


- (NSArray *)sortInputs:(NSArray *)inputs {
    
    // get the commands for Touch Down Event
    NSPredicate *inputPredicate = [NSPredicate predicateWithFormat:@"type != [c]%@", @"Do Not Display"];
    inputs = [inputs filteredArrayUsingPredicate:inputPredicate];
    

    // do not display inputs with "Do Not Display"
    
    // sort relays by number
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    
    return [inputs sortedArrayUsingDescriptors:sortDescriptors];
    
}

- (void)requestAllInputsStatus {
    
    [[InputControl sharedInstance] requestAllInputsStatus];
    
}




@end
