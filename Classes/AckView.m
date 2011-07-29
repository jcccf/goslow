//
//  AckView.m
//  goslowtest2
//
//  Created by Akshay Bapat on 11/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "AckView.h"


@implementation AckView
@synthesize navigationItem, tView, wView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.title = @"Acknowledgements";
	self.navigationItem.leftBarButtonItem.title = @"Back";
	tView.delegate = (id<UITextViewDelegate>) self;
	[tView becomeFirstResponder];
	NSString* ack1 = @"<div style=\"font-family: Helvetica\">";
	NSString* ack2 = @"<h3>Prof. Gilly Leshed, Assistant Professor, Information Science Department, Cornell University</h3><h3>Gannett Health Services, Cornell University</h3>";
	NSString* ack3 = @"<h2>The Going Slow Team</h2><ul><li>Akshay Bapat</li><li>Justin Cheng</li><li>Jeremy Crockett</li><li>Greg Thomas</li><li>Nikhil Nawathe</li><li>Kevin Tse</li></ul>";
	NSString* ack4 = @"<h2>Miscellany</h2><ul><li>Blank Diary Icon from http://bigkobe.deviantart.com</li><li>Tab Bar Icons from http://glyphish.com/</li></ul>";
	NSString* ack5 = @"</div>";
	NSString* acknowledgementsText = [NSString stringWithFormat:@"%@%@%@%@%@", ack1, ack2, ack3, ack4, ack5];
	[wView loadHTMLString:acknowledgementsText baseURL:[NSURL URLWithString:@"about:blank"]];
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
