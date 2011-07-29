//
//  ReflectColorViewController.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/26/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "ReflectColorViewController.h"
#import "ReflectTableViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/CoreAnimation.h>
#import "SyncManager.h"


@implementation ReflectColorViewController
@synthesize saveButton, colorWheel, tapMeButton, colorButton, rtv;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

-(IBAction)saveColor{
	
	UIColor *color = colorButton.backgroundColor;
	CGColorRef c = [color CGColor];
	const CGFloat *components = CGColorGetComponents(c);
	
	NSNumber *red = [NSNumber numberWithFloat:components[0]];
	NSNumber *green = [NSNumber numberWithFloat:components[1]];
	NSNumber *blue = [NSNumber numberWithFloat:components[2]];
	CGFloat alpha = components[3];
	
	NSArray *colors = [NSArray arrayWithObjects:red, green, blue, nil];
	
	if(alpha > 0){
		[[CoreDataManager getCoreDataManagerInstance] addColorReflection:colors];
	}
	
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save!" message:@"Your color reflection was saved to your diary!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	//[alert show];
	//[alert release];
	[[self navigationController] popViewControllerAnimated:YES];
	[rtv setSaveText:@"Saved Reflection"];
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:8]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self animateColorWheelToShow:YES duration:0.3];
	colorWheel.pickedColorDelegate = self;
	//[[colorButton layer] setCornerRadius:8.0f];
	[[colorButton layer] setMasksToBounds:YES];
	//[[colorButton layer] setBorderWidth:1.0f];
	self.navigationItem.title = @"Add Color";
	self.navigationItem.rightBarButtonItem = saveButton;
	//self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:4]];
}

- (IBAction) tapMe: (id)sender {
	[self animateColorWheelToShow:YES duration:0.3];
}

- (void) pickedColor:(UIColor *)color {
	//[self animateColorWheelToShow:NO duration:0.3];
	//self.view.backgroundColor = color;
	CGColorRef c = [color CGColor];
	const CGFloat *components = CGColorGetComponents(c);
	CGFloat red = components[0];
	CGFloat green = components[1];
	CGFloat blue = components[2];
	CGFloat alpha = components[3];
	
	if(alpha > 0){
		colorButton.backgroundColor = color;
		UIColor *newC = [UIColor colorWithRed:1-red green:1-green blue:1-blue alpha:1];
		[colorButton setTitleColor:newC forState:UIControlStateNormal];
	}
	[self.view setNeedsDisplay];
}

- (void) animateColorWheelToShow:(BOOL)show duration:(NSTimeInterval)duration {
	int x;
	float angle;
	float scale;
	if (show==NO) { 
		x = -320;
		angle = -3.12;
		scale = 0.01;
		self.colorWheel.hidden=YES;
	} else {
		x=0;
		angle = 0;
		scale = 1;
		[self.colorWheel setNeedsDisplay];
		self.colorWheel.hidden=NO;
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	
	CATransform3D transform = CATransform3DMakeTranslation(0,0,0);
	//transform = CATransform3DTranslate(transform,x,0,0);
	//transform = CATransform3DRotate(transform, angle,0,0,1);
	transform = CATransform3DScale(transform, scale,scale,1);
	self.colorWheel.transform=CATransform3DGetAffineTransform(transform);
	self.colorWheel.layer.transform=transform;
	[UIView commitAnimations];
}

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


- (void)dealloc {
    [super dealloc];
}


@end
