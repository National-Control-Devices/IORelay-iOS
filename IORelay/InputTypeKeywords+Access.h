//
//  InputTypeKeywords+Access.h
//  IORelay
//
//  Created by John Radcliffe on 9/24/14.
//  Copyright (c) 2014 com.radskysoftware. All rights reserved.
//

#import "InputTypeKeywords.h"

@interface InputTypeKeywords (Access)

+ (void)createInitialInputKeywordsInContext:(NSManagedObjectContext *)context;
+ (NSArray *)getTypeKeywordsInContext:(NSManagedObjectContext *)context;

@end
