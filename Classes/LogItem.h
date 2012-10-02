//
//  LogItem.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestItem.h"

@interface LogItem : NSObject {
	TestItem *testItem;
	NSDate *date;
	NSTimeInterval reactionTime;
	NSInteger clickCount;
}

@property (retain, nonatomic) TestItem *testItem;
@property (retain, nonatomic) NSDate *date;
@property (assign, nonatomic) NSTimeInterval reactionTime;
@property (assign, nonatomic) NSInteger clickCount;

- (id) initWithTest:(TestItem*)t;

@end
