//
//  AckView.h
//  goslowtest2
//
//  Created by Akshay Bapat on 11/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AckView : UIViewController {
	UITextView *tView;
	UINavigationItem *navigationItem;
	UIWebView *wView;
}

@property (nonatomic,retain) IBOutlet UITextView *tView;
@property (nonatomic,retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic,retain) IBOutlet UIWebView *wView;
@end
