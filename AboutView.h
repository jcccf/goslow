//
//  AboutView.h
//  goslowtest2
//
//  Created by Akshay Bapat on 11/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NotificationTime;

@interface AboutView : UIViewController {
	UITextView *tView;
	UINavigationItem *navigationItem;
}

@property (nonatomic,retain) IBOutlet UITextView *tView;
@property (nonatomic,retain) IBOutlet UINavigationItem *navigationItem;

@end
