//
//  ResultViewController.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ResultViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
	UITextView *textView;
	NSString *logFile;
	UILabel *label;
}

@property (retain, nonatomic) NSString *logFile;

- (void) loadLog:(NSString*)path;

@end
