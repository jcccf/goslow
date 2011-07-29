//
//  NotificationManager.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "NotificationManager.h"


@implementation NotificationManager

@synthesize eveningTime;
@synthesize morningTime;
@synthesize eveningNotification;
@synthesize morningNotification;
@synthesize suggestion;

static NotificationManager *sharedInstance = nil;

+(NotificationManager *)getNotificationManagerInstance{
	@synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

-(void)scheduleNotificationEvening{
	
}

-(void)scheduleNotificationMorning{
	
}


@end
