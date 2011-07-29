//
//  Screen3ViewController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reflection.h"
#import "ReflectColorViewController.h"
#import "ReflectCameraViewController.h"
#import "ReflectTextViewController.h"

@interface Screen3ViewController : UIViewController{
	ReflectColorViewController *reflectColorViewController;
	UIImagePickerController *reflectCameraViewController;
	ReflectTextViewController *reflectTextViewController;
	UITableView *tableView;
	
}


-(void)storeReflection:(Reflection *)r;

@property (nonatomic,retain) UIImagePickerController *reflectCameraViewController;
@property (nonatomic,retain) ReflectTextViewController *reflectTextViewController;
@property (nonatomic,retain) ReflectColorViewController *reflectColorViewController;
@property (nonatomic,retain) IBOutlet UITableView *tableView;
-(IBAction)goToCamera:(id)sender;
-(IBAction)goToText:(id)sender;
-(IBAction)goToColor:(id)sender;

@end
