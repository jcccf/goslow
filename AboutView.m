//
//  AboutView.m
//  goslowtest2
//
//  Created by Akshay Bapat on 11/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "AboutView.h"


@implementation AboutView
@synthesize navigationItem, tView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	self.navigationItem.title = @"About";
	self.navigationItem.leftBarButtonItem.title = @"Back";
	tView.delegate = (id<UITextViewDelegate>) self;
	[tView becomeFirstResponder];
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
