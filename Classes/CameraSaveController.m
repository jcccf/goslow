//
//  CameraSaveController.m
//  goslowtest2
//
//  Created by Gregory Thomas on 12/1/10.
//  Copyright 2010 Cornell University. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CameraSaveController.h"


static BOOL s = NO;

@implementation CameraSaveController

@synthesize cameraSwitch, backLabel;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	backLabel.layer.cornerRadius = 8;
	backLabel.layer.borderColor = [UIColor grayColor].CGColor;
	backLabel.layer.borderWidth = 1.0;
	[[NSUserDefaults standardUserDefaults] setBool:cameraSwitch.on forKey:@"CameraRollSave"];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(IBAction)changeCameraOptions:(id)sender{
	s = !s;
		[[NSUserDefaults standardUserDefaults] setBool:s forKey:@"CameraRollSave"];


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
