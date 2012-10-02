//
//  SettingsViewController.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *default_email;

@interface SettingsViewController : UITableViewController <UITextFieldDelegate> {

}

+ (void) loadSettings;

@end
