//
//  LogItem.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LogItem.h"
#import "TestItem.h"

@implementation LogItem
@synthesize testItem, date, reactionTime, clickCount;

- (id)initWithTest:(TestItem*)t {
    if ((self = [super init])) {
		self.testItem = t;
    }
    return self;
}

- (void) dealloc {
	self.testItem = nil;
	self.date = nil;
	[super dealloc];
}

@end
