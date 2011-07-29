//
//  ReflectColorViewController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/26/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPickerImageView.h"
#import "CoreDataManager.h"

@class ReflectTableViewController;

@interface ReflectColorViewController : UIViewController {

	//UINavigationItem *navigationItem;
	UIBarButtonItem *saveButton;
	
	ColorPickerImageView* colorWheel;
	UIButton* tapMeButton;
	UIButton* colorButton;
	ReflectTableViewController* rtv;
}

//@property (nonatomic,retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic,retain) ReflectTableViewController* rtv;
@property (nonatomic,retain) IBOutlet ColorPickerImageView* colorWheel;
@property (nonatomic,retain) IBOutlet UIButton* tapMeButton;
@property (nonatomic,retain) IBOutlet UIButton* colorButton;

- (IBAction) tapMe: (id)sender;
- (void) pickedColor: (UIColor*) color;
- (void) animateColorWheelToShow:(BOOL)show duration:(NSTimeInterval)duration;

-(IBAction)saveColor;

@end
