//
//  RunViewController.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestItem.h"

@interface RunViewController : UIViewController <UIAlertViewDelegate,AVAudioPlayerDelegate> {
	NSDate *lastStimuliTime;
	NSString *logName;
	NSString *logFile;
	int clickCount;
	id delegate;
	SEL cancelSelector;
	NSArray *testItems;
	NSMutableArray *logItems;
	NSMutableDictionary *testImages;
	int testIndex;
	TestItem *currentTest;
	NSStringEncoding currentEncoding;
}

@property (assign, nonatomic) id delegate;
@property (assign, nonatomic) SEL cancelSelector;
@property (retain, nonatomic) NSArray *testItems;
@property (retain, nonatomic) NSMutableArray *logItems;
@property (retain, nonatomic) NSMutableDictionary *testImages;

- (void) loadTest:(NSString*)filename;
- (void) writeLogFile;

@end
