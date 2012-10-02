//
//  ResultViewController.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ResultViewController.h"
#import "SettingsViewController.h"

@implementation ResultViewController
@synthesize logFile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setTitle:@"Resultat"];
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if(result==MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fel!" message:@"Kunde ej skicka email"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	[self dismissModalViewControllerAnimated:YES];
	
}

- (void) sendByMail:(NSString*)path {
	if(![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ej stöd" message:@"Du behöver aktivera ett email konto i Mail programmet"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	NSString *name = [path lastPathComponent];
	[picker setSubject:[@"iCPT Logfil: " stringByAppendingString:name]];
	NSArray *toRecipients = [NSArray arrayWithObject:default_email];
	[picker setToRecipients:toRecipients];
	NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"application/octet-stream" fileName:name];
	NSString *emailBody = [NSString stringWithFormat:@"logfil bifogad: '%@'",name];
	[picker setMessageBody:emailBody isHTML:NO];	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}


- (void)uploadLog {
	[self sendByMail:self.logFile];
}

- (void) alertView: (UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)i {
	if(i==1) {
		if([[NSFileManager defaultManager] removeItemAtPath:self.logFile error:NULL]) {
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}
- (void)deleteLog {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Ta bort?"
						  message:@"Är du säker på att du vill ta bort denna logfil?"
						  delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja",nil];
	[alert show];
	[alert release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 28, 300, 340)];
	textView.font = [UIFont fontWithName:@"Courier-Bold" size:16];
	textView.textColor = [UIColor colorWithWhite:0.2 alpha:1];
	textView.editable = NO;
	[self.view addSubview: textView];
	self.view.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1];
	[textView release];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 300, 16)];
	label.font = [UIFont boldSystemFontOfSize:14];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:label];
	[label release];

	NSArray* toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:@"skicka"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(uploadLog)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:@"ta bort"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(deleteLog)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 nil];
    self.toolbarItems = toolbarItems;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void) loadLog:(NSString*)path {
    NSLog(@"Loading log %@",path);
    if(!label) {
        //force creation of view
        [self view];
    }
	NSStringEncoding enc;
	NSString *contents = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
	NSArray *lines = [contents componentsSeparatedByString:@"\n"];
	self.logFile = path;
	label.text = [[path lastPathComponent] stringByDeletingPathExtension];
	
	int missed[2] = {0,};
	int wrong[2] = {0,};
	int totalm[2] = {0,};
	int totalw[2] = {0,};
	double rt[2] = {0,};
	int clickTotal[2] = {0,};	
	
	for (NSString *line in lines) {
		NSArray *words = [line componentsSeparatedByString:@","];
		
		if([words count] <= 1) { //ignore empty lines
			continue;
		}
		if([line hasPrefix:@"\""]) { //ignore header line.. a bit ugly but works.
			continue;
		}
		
		int clickCount = [[words objectAtIndex:1] integerValue];
		double reactionTime = [[words objectAtIndex:2] doubleValue];
		int type = [[[words objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] characterAtIndex:0];
		BOOL expectation = [[words objectAtIndex:7] boolValue];
		BOOL failed = [[words objectAtIndex:8] boolValue];

			if(type=='i') continue;
			int i = type=='v'?0:1;
			if(clickCount==0) { //for each stimuli, not click
				if(failed) {
					if(expectation)
						missed[i]++;
					else
						wrong[i]++;
				}
				if(expectation)
					totalm[i]++;
				else
					totalw[i]++;
			}
			if(clickCount==1 && expectation) { //only for first clicks and go stimula.
				rt[i] += reactionTime;
				clickTotal[i]++;
			}
	}
	textView.text = [NSString stringWithFormat:
	 @"MISSAR\ntotalt:%5.1f%%\n  bild:%5.1f%%\n  ljud:%5.1f%%\n\n"
	 "FELTAGNINGAR\ntotalt:%5.1f%%\n  bild:%5.1f%%\n  ljud:%5.1f%%\n\n"
	 "REAKTIONSTID\ntotalt:%6.0fms\n  bild:%6.0fms\n  ljud:%6.0fms",
	 (float)(missed[0]+missed[1])/(float)(totalm[0]+totalm[1])*100,
	 (float)totalm[0]?missed[0]/(float)totalm[0]*100:0,
	 (float)totalm[1]?missed[1]/(float)totalm[1]*100:0,
	 (float)(wrong[0]+wrong[1])/(float)(totalw[0]+totalw[1])*100,
	 (float)totalw[0]?wrong[0]/(float)totalw[0]*100:0,
	 (float)totalw[1]?wrong[1]/(float)totalw[1]*100:0,
	 (clickTotal[0]+clickTotal[1])?(rt[0]+rt[1])/((double)clickTotal[0]+clickTotal[1])*1000:0,
	 clickTotal[0]?rt[0]/(double)clickTotal[0]*1000:0,
	 clickTotal[1]?rt[1]/(double)clickTotal[1]*1000:0
	 ];
}

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


- (void)dealloc {
	self.logFile = nil;
    [super dealloc];
}


@end
