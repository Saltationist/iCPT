//
//  RunViewController.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RunViewController.h"
#import "TestItem.h"
#import "LogItem.h"
#import "ResultViewController.h"

@implementation RunViewController
@synthesize delegate, cancelSelector;
@synthesize testItems, testImages, logItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)loadView {
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	CGRect screenBounds = CGRectMake(0, 0, screenSize.width, screenSize.height);

	UIView *v = [[UIView alloc] initWithFrame:screenBounds];
	v.opaque = YES;
	v.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.4 alpha:1];
	self.view = v;
    [v release];
}

- (void)cancelTest {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextItem) object:nil];
	[delegate performSelector:cancelSelector withObject:nil];
}

//- (void)flashOff {
//	self.view.backgroundColor = [UIColor blueColor];
//	((UIImageView*)[self.testImages objectForKey:@"ett.png"]).hidden = YES;
//}

- (void)addLogWithTest:(TestItem*)t date:(NSDate *)d reactionTime:(NSTimeInterval)dt clickCount:(NSInteger)c {
	LogItem *l = [[LogItem alloc] initWithTest:t];
	l.date = d;
	l.reactionTime = dt;
	l.clickCount = c;
	[self.logItems addObject:l];
	[l release];	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if(currentTest.type == 'i' && clickCount == 0) {
		currentTest.image.hidden = YES;
		[self performSelector:@selector(nextItem) withObject:nil afterDelay:currentTest.duration];
	}
	if(currentTest.type != 'i') {
		NSDate *now = [NSDate date];
		NSTimeInterval dt = [now timeIntervalSinceDate:lastStimuliTime];
		currentTest.failed = !currentTest.expectation;
		clickCount++;
		[self addLogWithTest:currentTest date:now reactionTime:dt clickCount:clickCount];
	}
	
	[self performSelector:@selector(cancelTest) withObject:nil afterDelay:5];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelTest) object:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.opaque = YES;
	self.view.backgroundColor = [UIColor redColor];
}*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) hideVisual {
	currentTest.image.hidden = YES;
}

- (void) doVisual {
	currentTest.image.hidden = NO;
	[self performSelector:@selector(hideVisual) withObject:nil afterDelay:currentTest.length];
	[self performSelector:@selector(nextItem) withObject:nil afterDelay:currentTest.duration];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if(flag) {
		player.currentTime = 0;
		[player prepareToPlay];
	}
}
- (void) doSound {
	[currentTest.sound play];
	[self performSelector:@selector(nextItem) withObject:nil afterDelay:currentTest.duration];	
}
- (void) doInstruction {
	currentTest.image.hidden = NO;
}

- (void) testDone {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelTest) object:nil];
	[self writeLogFile];
	[delegate performSelector:cancelSelector withObject:logFile];
}

- (void) nextItem {
	TestItem *t;
	if(testIndex >= [self.testItems count]) {
		[self testDone];
		return;
	}
	t = currentTest = [self.testItems objectAtIndex:testIndex];
	//FIXME: would be neater to just have a SEL field in TestItem and do
	//[self performSelector:t.actionSel];
	NSLog(@"ITEM %d duration: %g",testIndex,t.duration);

	[lastStimuliTime release];
	lastStimuliTime = [[NSDate date] retain];
	clickCount = 0;

	currentTest.failed = currentTest.expectation;
	switch(t.type) {
		case 'i':
			currentTest.failed = NO;
			[self doInstruction];
			break;
		case 'v':
			[self addLogWithTest:t date:lastStimuliTime reactionTime:0 clickCount:0];
			[self doVisual];
			break;
		case 'a':
			[self addLogWithTest:t date:lastStimuliTime reactionTime:0 clickCount:0];
			[self doSound];
			break;
		default:
			NSLog(@"Unknown test item type: %c",t.type);
	}
	testIndex++;
}

- (void) startTest {
	testIndex = 0;
	currentTest = nil;
	self.logItems = [NSMutableArray arrayWithCapacity:32];
	[self nextItem];
}

- (void) loadTest:(NSString *)filename {
	NSString *contents = [NSString stringWithContentsOfFile:filename usedEncoding:&currentEncoding error:nil];
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:16];
	NSMutableDictionary *images = [NSMutableDictionary dictionaryWithCapacity:4]; //actually also for sounds!

	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];


	//FIXME: should we ignore headerlines? like "Foo", "Bar", ...
	for (NSString *line in lines) {
		NSArray *words = [line componentsSeparatedByString:@","];
		
		if([words count] <= 1) { //ignore empty lines
			continue;
		}
		if([words count] != 5) {
			NSLog(@"testline has other than 5 values, ignoring: %@",line);
			continue;
		}
		
		TestItem *t = [[TestItem alloc] init];
		t.type = [[words objectAtIndex:0] characterAtIndex:0];
		t.filename = [[words objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		t.length = [[words objectAtIndex:2] doubleValue];
		t.duration = [[words objectAtIndex:3] doubleValue];
		t.expectation = [[words objectAtIndex:4] boolValue];
		t.failed = NO;
		
		//if type == 'v':
		//use a hashtable for imageviews, t.filename is key. if not found in the table, make a new one
		//then set t.image to the pointer..
		if(t.type == 'v' || t.type == 'i') {
			UIImageView *iv = [images objectForKey:t.filename];
			if(!iv) {
				NSString *fn = [documentsDirectory stringByAppendingPathComponent:t.filename];
				if(![[NSFileManager defaultManager] fileExistsAtPath:fn])
					fn = [[NSBundle mainBundle] pathForResource:t.filename ofType:nil inDirectory:@"Stimuli"];
					
				UIImage *img = [UIImage imageWithContentsOfFile:fn];
				iv = [[[UIImageView alloc] initWithImage:img] autorelease];
				iv.frame = self.view.frame;
				iv.hidden = YES;
				[self.view addSubview:iv];
				[images setObject:iv forKey:t.filename];
				NSLog(@"creating image view for %@",t.filename);
			}
			t.image = iv;
		}
		if(t.type == 'a') {
			AVAudioPlayer *p = [images objectForKey:t.filename];
			if(!p) {
				NSString *fn = [documentsDirectory stringByAppendingPathComponent:t.filename];
				if(![[NSFileManager defaultManager] fileExistsAtPath:fn])
					fn = [[NSBundle mainBundle] pathForResource:t.filename ofType:nil inDirectory:@"Stimuli"];
				
				NSURL *url = [NSURL fileURLWithPath:fn];
				p = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
				p.delegate = self;
				[p prepareToPlay];
				[images setObject:p forKey:t.filename];
				[p release];
				NSLog(@"creating audio player for %@",t.filename);
			}
			t.sound = p;
		}
		
		[items addObject:t];
		NSLog(@"%c:%@:%g:%g:%d",t.type,t.filename,t.length,t.duration,t.expectation);
		[t release];
	}
	self.testItems = items;
	self.testImages = images;
	
	logName = [NSString stringWithFormat:@"%@ %@",
			   [[filename lastPathComponent] stringByDeletingPathExtension],
			   [[NSDate date] description]
	];
	[logName retain];
	
	[self startTest];
}

- (void)writeLogFile {
	NSString *txt = @"\"Date\", \"ClickCount\", \"ReactionTime\", \"Type\", \"File\", \"Length\", \"Duration\", \"Expectation\", \"Failed\"\n";
	for(LogItem *l in self.logItems) {
		txt = [txt stringByAppendingFormat: @"%@, %d, %g, %c, %@, %g, %g, %d, %d\n",
			[l.date description],
			l.clickCount,
			l.reactionTime,
			l.testItem.type,
			l.testItem.filename,
			l.testItem.length,
			l.testItem.duration,
			l.testItem.expectation,
			l.testItem.failed];
	}

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *fn = [documentsDirectory stringByAppendingPathComponent:[logName stringByAppendingString:@".log"]];
	[txt writeToFile:fn atomically:YES encoding:currentEncoding error:nil];
	[logFile release];
	logFile = [fn retain];
	NSLog(@"Wrote logfile to %@",fn);
}

- (void)dealloc {
    [super dealloc];
}


@end
