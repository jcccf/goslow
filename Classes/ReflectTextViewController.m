//
//  ReflectTextViewController.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/26/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "ReflectTextViewController.h"
#import "ReflectTableViewController.h"
#import "SyncManager.h"
#include <unistd.h>



@implementation ReflectTextViewController
@synthesize navigationItem, saveButton, tView, rtv;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

-(IBAction)saveText{
	//TODO Check for empty text
	NSString *text = tView.text;
	[[CoreDataManager getCoreDataManagerInstance] addTextReflection:text];
	
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:text];
	[[SyncManager getSyncManagerInstance] syncData];

	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save!" message:@"Your text reflection was saved to your diary!" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[alert show];
	[alert release];
	[alert dismissWithClickedButtonIndex:0 animated:YES];*/
	[[self navigationController] popViewControllerAnimated:YES];
	tView.text = @"";
	[rtv setSaveText:@"Saved Reflection"];
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:9]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	self.navigationItem.title = @"Add Text";
	self.navigationItem.leftBarButtonItem.title = @"Back";
	tView.delegate = (id<UITextViewDelegate>) self;
	[tView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:5]];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
		
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
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
    [super dealloc];
}


@end
