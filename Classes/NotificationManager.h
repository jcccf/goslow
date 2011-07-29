//
//  NotificationManager.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Suggestion.h"

@interface NotificationManager : NSObject {

	NSDate *eveningTime;
	NSDate *morningTime;
	UILocalNotification *eveningNotification;
	UILocalNotification *morningNotification;
	
	//we need a reference to the current suggestion that is being displayed so we can update the notifications accordingly
	Suggestion *suggestion;
	
	
}

@property (nonatomic,retain) NSDate *eveningTime;
@property (nonatomic,retain) NSDate *morningTime;
@property (nonatomic,retain) UILocalNotification *eveningNotification;
@property (nonatomic,retain) UILocalNotification *morningNotification;
@property (nonatomic,retain) Suggestion *suggestion;



+(NotificationManager *)getNotificationManagerInstance;
-(void)scheduleNotificationMorning;
-(void)scheduleNotificationEvening;
@end
