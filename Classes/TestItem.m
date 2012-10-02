//
//  TestItem.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestItem.h"


@implementation TestItem
@synthesize type, filename, length, duration, expectation, image, sound, failed;

- (void) dealloc {
	self.filename = nil;
	self.image = nil;
	self.sound = nil;
	[super dealloc];
}

@end
