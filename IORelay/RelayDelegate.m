//
//  RelayDelegate.m
//  IORelay
//
//  Created by John Radcliffe on 10/3/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "RelayDelegate.h"
#import "Relay.h"
#import "RelayControl.h"
#import "TCPCommunications.h"

static RelayDelegate *_sharedInstance;


@implementation RelayDelegate



# pragma mark - Object Lifecycle
+ (RelayDelegate *)sharedInstance {
    //  Static local predicate must be initialized to 0
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RelayDelegate alloc] init];
        
    });
    
    return _sharedInstance;
}

#pragma mark - Build Relay UI
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
    
    // Listen for Relay Control to tell us to update relays
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRelays:) name:@"RelaysNeedUpdate" object:nil];
    
    return self;
}


//- (void)resetRelayInfo {
//    
//    self.tableSections = nil;
//    self.relayStatus = nil;
//    
//    [[RelayControl sharedInstance] resetRelayInfo];
//    
//}

- (NSMutableArray *)getRelayInfoForDevice:(Device *)device {
    
    self.relayStatus = [[RelayControl sharedInstance] getAllRelayStatus];
    
    return [self buildTableSectionsFromArray:[device.relays allObjects]];
    
}

- (NSMutableArray *)buildTableSectionsFromArray:(NSArray *)relays {
    
    NSArray *sortedRelays = [self sortRelays:relays];
    
    NSString *momentaryLabel;

    self.tableSections = [[NSMutableArray alloc] init];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [sortedRelays count]; i++) {
        
        Relay *relay = [sortedRelays objectAtIndex:i];
        
        UITableViewCell *displayCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DeviceControl"];
        [displayCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIButton *relayState = [self createRelayStateWithConstraintsInCell:displayCell];
        [relayState setTag:i];
        
        // make sure we have status info
        if ([self.relayStatus count] > i ) {
            
            // if the relay is flagged as momentary add the targets for the press and release of the button
            if ([relay.momentary boolValue]) {
                momentaryLabel = @"Momentary";
                // add target for press
                [relayState setBackgroundImage:[UIImage imageNamed:@"Button-On"] forState:UIControlStateHighlighted];
                [relayState addTarget:self.parentViewController action:@selector(momentaryRelayButtonPressed:) forControlEvents:UIControlEventTouchDown];
                [relayState addTarget:self.parentViewController action:@selector(momentaryRelayButtonReleased:) forControlEvents:UIControlEventTouchUpInside];

            // we have a "run of the mill" relay so set up target to toggle state
            } else {
                // add target if we have verified a relay for this button.
                momentaryLabel = nil;
                [relayState setBackgroundImage:[UIImage imageNamed:@"Button-Off"] forState:UIControlStateHighlighted];
                [relayState addTarget:self.parentViewController action:@selector(relayButtonPressed:) forControlEvents:UIControlEventTouchDown];

            }


            NSNumber *status = [self.relayStatus objectAtIndex:i];
            
            if ([status boolValue]) {
//                [relayState setBackgroundImage:[self imageWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
                [relayState setBackgroundImage:[UIImage imageNamed:@"Button-On"] forState:UIControlStateNormal];
            } else {
                
//                [relayState setBackgroundImage:[self imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
                [relayState setBackgroundImage:[UIImage imageNamed:@"Button-Off"] forState:UIControlStateNormal];

            }

        } else {
            
            [relayState setBackgroundImage:[UIImage imageNamed:@"Button-Off"] forState:UIControlStateNormal];
            [relayState addTarget:self.parentViewController action:@selector(relayButtonPressed:) forControlEvents:UIControlEventTouchDown];
 
        }
        
        UILabel *relayName = [self createDetailLabelWithConstraintsInCell:displayCell];
        relayName.text = relay.name;
        
        UILabel *momentary = [self createMomentaryLabelWithConstraintsInCell:displayCell];
        momentary.text = momentaryLabel;
        
        [list addObject:displayCell];
        
        [self.tableSections addObject:list];

    }

    return self.tableSections;

}

- (NSArray *)sortRelays:(NSArray *)relays {
    
    // sort relays by number
    NSSortDescriptor *numberSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:numberSortDescriptor];
    
    return [relays sortedArrayUsingDescriptors:sortDescriptors];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Relay Communications

- (void)refreshRelays:(NSNotification *)notification {
    
        // reload the table
        [self requestAllRelaysStatus];
}


- (void)requestAllRelaysStatus {
    
    [[RelayControl sharedInstance] requestAllRelaysStatus];
    
}

- (void)toggleRelay:(NSNumber *)relay {
    NSLog(@"toggleRelay RelayDelegate.m");
    
    // verify that we have a loaded relaystatus?
    if ([self.relayStatus count] == 0) {
        
        NSString *message = [NSString stringWithFormat:@"No Relay Status Information"];
        
        // pass response data back to relayControl for processing
        NSDictionary *userInfo = @{@"title" : @"Relay Information Error" , @"error" : message};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAlert" object:nil userInfo:userInfo];


    } else {
        
        // get the current status - convert from string to nsnumber to send
        NSNumber *currentState = [NSNumber numberWithInt:[[self.relayStatus objectAtIndex:[relay intValue]] intValue]];
        [[RelayControl sharedInstance] toggleRelay:relay fromState:currentState];
        
        // we will refresh the ui with a notification from TCPCommunications when done

        
    }
    
    
}

- (void)toggleMomentaryRelay:(NSNumber *)relay withAction:(NSString *)action {
    
    // we have pressed the momentary button
    if ([action isEqualToString:@"Pressed"]) {
        
        // turn the relay on
        [[RelayControl sharedInstance] toggleMomentaryRelay:relay forState:@"On"];

        
    // we have released the momentary button
    } else if ([action isEqualToString:@"Released"]) {
        
        // turn the relay off
        // turn the relay on
        [[RelayControl sharedInstance] toggleMomentaryRelay:relay forState:@"Off"];

        
    }
    
    
}

// create restraints on detail label view
- (UIButton *)createRelayStateWithConstraintsInCell:(UITableViewCell *)displayCell {
    
    UIButton *relayState = [[UIButton alloc] init];
    
    // add to cell now so restraints will work
    [displayCell.contentView addSubview:relayState];
    
    // autolayout restraint to use the entire cell width
    // use only restraints specified here
    relayState.translatesAutoresizingMaskIntoConstraints = NO;
    
    // restraint for height
    NSLayoutConstraint *relayStateHeight = [NSLayoutConstraint constraintWithItem:relayState
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:40];
    [relayState addConstraint:relayStateHeight];
    
    // restraint for width
    NSLayoutConstraint *relayStateWidth = [NSLayoutConstraint constraintWithItem:relayState
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:40];
    
    
    
    [relayState addConstraint:relayStateWidth];
    
    // restraint for left padding
    NSLayoutConstraint *relayStateLeft = [NSLayoutConstraint constraintWithItem:relayState
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:displayCell
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:20];

    [displayCell addConstraint:relayStateLeft];
    

    
    // restraint for bottom
    NSLayoutConstraint *relayStateBottom = [NSLayoutConstraint constraintWithItem:relayState
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:displayCell
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:-5];
    
    
    
    [displayCell addConstraint:relayStateBottom];
    

    return relayState;
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
                                                                    constant:30];  // [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 100, 30)];
    [detailLabel addConstraint:labelHeight];
    
    // restraint for width
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:150];
    
    
    
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
    
    
    // restraint for left padding
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:displayCell
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:70];

    [displayCell addConstraint:labelLeft];
    
//    // restraint for right padding
//    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:detailLabel
//                                                                  attribute:NSLayoutAttributeTrailing
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:displayCell
//                                                                  attribute:NSLayoutAttributeRight
//                                                                 multiplier:1.0
//                                                                   constant:-20];
//    
//    [displayCell addConstraint:labelRight];
//    
    // since we glue this to the right - allign text to end there
    detailLabel.textAlignment = NSTextAlignmentLeft;
    
    return detailLabel;
}

// create restraints on detail label view
- (UILabel *)createMomentaryLabelWithConstraintsInCell:(UITableViewCell *)displayCell {
    
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
                                                                    constant:30];  // [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 100, 30)];
    [detailLabel addConstraint:labelHeight];
    
    // restraint for width
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:50];
    
    
    
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
    

    // restraint for right padding
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:detailLabel
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:displayCell
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:-20];

    [displayCell addConstraint:labelRight];
    
  //   since we glue this to the right - allign text to end there
    detailLabel.textAlignment = NSTextAlignmentRight;
    detailLabel.adjustsFontSizeToFitWidth = YES;
    
    return detailLabel;
}




@end
