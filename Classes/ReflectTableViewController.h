//
//  ReflectTableViewController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reflection.h"
#import "ReflectColorViewController.h"
#import "ReflectCameraViewController.h"
#import "ReflectTextViewController.h"
#import "CoreDataManager.h"

@interface ReflectTableViewController : UITableViewController {
	ReflectColorViewController *reflectColorViewController;
	UIImagePickerController *reflectCameraViewController;
	ReflectTextViewController *reflectTextViewController;
	CoreDataManager *coreDataManager;
	UILabel* savedLabel;
	double hackTime;
}

-(void)storeReflection:(Reflection *)r;
-(void)setSaveText:(NSString *)s;

-(void)goToCamera;
-(void)goToText;
-(void)goToColor;

@property (nonatomic,retain) IBOutlet UILabel* savedLabel;

@property (nonatomic,retain) UIImagePickerController *reflectCameraViewController;
@property (nonatomic,retain) ReflectTextViewController *reflectTextViewController;
@property (nonatomic,retain) ReflectColorViewController *reflectColorViewController;
@property (nonatomic,retain) CoreDataManager *coreDataManager;

@end
