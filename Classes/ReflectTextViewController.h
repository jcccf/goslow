//
//  ReflectTextViewController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/26/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataManager.h"

@class ReflectTableViewController;

@interface ReflectTextViewController : UIViewController {
	UITextView *tView;
	UINavigationItem *navigationItem;
	UIBarButtonItem *saveButton;
	ReflectTableViewController* rtv;
	
}
@property (nonatomic,retain) ReflectTableViewController* rtv;
@property (nonatomic,retain) IBOutlet UITextView *tView;
@property (nonatomic,retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *saveButton;

-(IBAction)saveText;
@end
