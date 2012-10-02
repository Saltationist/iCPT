//
//  TestsViewController.m
//  CPT
//
//  Created by Jonatan Liljedahl on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestsViewController.h"
#import "RunViewController.h"
#import "ResultViewController.h"

@implementation TestsViewController
@synthesize filelist;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
		[self setTitle:@"Välj test"];
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void) updateFileList {
	// add from Documents:
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
	NSMutableArray *list = [NSMutableArray arrayWithCapacity:16];
	for(NSString *s in docs) {
		if([s hasSuffix:@".csv"])
			[list addObject: [documentsDirectory stringByAppendingPathComponent:s]];
	}
	// add tests shipped with app:
	[list addObjectsFromArray:[[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"Tests"]];
	self.filelist = list;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[self updateFileList];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//	self.navigationController.toolbarHidden = YES;
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
    }
    
	cell.textLabel.text = [[[self.filelist objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


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

- (void)testDone:(NSString*)fn {
    [self dismissModalViewControllerAnimated:YES];
	if(fn) {
		ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:nil bundle:nil];
		[self.navigationController pushViewController:rvc animated:NO];
//		rvc.textView.text = stats;
		[rvc loadLog:fn];
		[rvc release];
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	RunViewController *viewController = [[RunViewController alloc] initWithNibName:nil bundle:nil];
	viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[UIApplication sharedApplication].statusBarHidden = YES;

	[self presentModalViewController:viewController animated:YES];
	viewController.delegate = self;
	viewController.cancelSelector = @selector(testDone:);
	[viewController loadTest:[self.filelist objectAtIndex:indexPath.row]];
	[viewController release];
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

