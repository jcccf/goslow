//
//  HistoryReflectionViewController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryReflectionViewController : UIViewController {
	//UINavigationItem *navigationItem;
	UITextView *t;
	UIImageView *i;
	NSString *te;
	UIImage *im;
}

//@property(nonatomic,retain) IBOutlet UINavigationItem *navigationItem;
@property(nonatomic,retain) IBOutlet UITextView *t;
@property(nonatomic,retain) IBOutlet UIImageView *i;
@property(nonatomic,retain) NSString *te;
@property(nonatomic,retain) UIImage *im;
@end
