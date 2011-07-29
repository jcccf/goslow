//
//  CameraSaveController.h
//  goslowtest2
//
//  Created by Gregory Thomas on 12/1/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CameraSaveController : UIViewController {
	
	IBOutlet UISwitch *cameraSwitch;
	IBOutlet UILabel *backLabel;

}

@property(nonatomic,retain) UISwitch *cameraSwitch;
@property(nonatomic,retain) UILabel *backLabel;
-(IBAction)changeCameraOptions:(id)sender;

@end
