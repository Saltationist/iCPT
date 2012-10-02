//
//  LogsViewController.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface LogsViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
	NSArray *filelist;
	NSString *selectedLog;
}

@property (retain, nonatomic) NSArray *filelist;
@property (retain, nonatomic) NSString *selectedLog;

@end
