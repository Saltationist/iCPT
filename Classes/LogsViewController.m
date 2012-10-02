//
//  LogsViewController.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LogsViewController.h"
#import "ResultViewController.h"
#import "SettingsViewController.h"

@implementation LogsViewController
@synthesize filelist, selectedLog;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		[self setTitle:@"Loggar"];
		
    }
    return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)updateFileList {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
	NSMutableArray *logs = [NSMutableArray arrayWithCapacity:16];
	for(NSString *s in docs) {
		if([s hasSuffix:@".log"])
			[logs addObject: [documentsDirectory stringByAppendingPathComponent:s]];
	}
	self.filelist = logs;
}

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

- (void) uploadAll {
	if(![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ej stöd" message:@"Du behöver aktivera ett email konto i Mail programmet"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	NSString *body = @"logfiler bifogade:\n";
	for(NSString *path in self.filelist) {
		NSString *name = [path lastPathComponent];
		NSData *myData = [NSData dataWithContentsOfFile:path];
		[picker addAttachmentData:myData mimeType:@"application/octet-stream" fileName:name];
		body = [body stringByAppendingFormat:@"- %@\n",name];
	}
	
	[picker setSubject:@"iCPT Loggar"];
	NSArray *toRecipients = [NSArray arrayWithObject:default_email];
	[picker setToRecipients:toRecipients];	
	NSString *emailBody = body;
	[picker setMessageBody:emailBody isHTML:NO];	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void) alertView: (UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)i {
	if(i==1 && alert.title == @"Ta bort alla?") {
		for(NSString *path in self.filelist) {
			[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
		}
		[self updateFileList];
		[self.tableView reloadData];
	}
}
- (void)deleteAll {
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Ta bort alla?"
						  message:@"Är du säker på att du vill ta bort ALLA logfiler?"
						  delegate:self cancelButtonTitle:@"Nej" otherButtonTitles:@"Ja",nil];
	[alert show];
	[alert release];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

	NSArray* toolbarItems = [NSArray arrayWithObjects:
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:@"skicka alla"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(uploadAll)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 [[[UIBarButtonItem alloc] initWithTitle:@"ta bort alla"
															  style:UIBarButtonItemStyleBordered
															 target:self
															 action:@selector(deleteAll)] autorelease],
							 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil] autorelease],
							 nil];
    self.toolbarItems = toolbarItems;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self updateFileList];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//	self.navigationController.toolbarHidden = YES;
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.filelist count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
    // Configure the cell...
	cell.textLabel.text = [[[self.filelist objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSString *path = [self.filelist objectAtIndex:indexPath.row];
		if([[NSFileManager defaultManager] removeItemAtPath:path error:NULL]) {
			[self updateFileList];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
    }   
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.selectedLog = [self.filelist objectAtIndex:indexPath.row];
	ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:nil bundle:nil];
	[self.navigationController pushViewController:rvc animated:YES];
	[rvc loadLog:self.selectedLog];
	
	[rvc release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	self.filelist = nil;
    [super dealloc];
}


@end

