//
//  InputTypeKeywords.h
//  IORelay
//
//  Created by John Radcliffe on 11/19/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InputTypeKeywords : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;

@end
