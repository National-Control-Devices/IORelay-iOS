//
//  InputTableViewController.h
//  IORelay
//
//  Created by John Radcliffe on 9/16/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device+Access.h"
#import "Input+Access.h"

@interface InputTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) Device *device;

- (void)setSelectedDevice:(Device *)device;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
