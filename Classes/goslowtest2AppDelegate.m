//
//  goslowtest2AppDelegate.m
//  goslowtest2
//
//  Created by Kevin Tse on 10/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "goslowtest2AppDelegate.h"
#import "NotificationTime.h"
#import "Reachability.h"

#import "CoreDataManager.h"

@implementation goslowtest2AppDelegate
@synthesize tabController;
@synthesize window;
@synthesize reflectionNotification;
@synthesize suggestionNotification;
@synthesize timeMorning;
@synthesize timeEvening;
@synthesize isNotFirstRun;
@synthesize navigationController, labelTheme;

#pragma mark -
#pragma mark Application lifecycle


- (void) reachabilityChanged: (NSNotification* )note

{
	
    Reachability* curReach = [note object];
	
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);

    //[self updateInterfaceWithReachability: curReach]; // Seems to be redundant
	
}

-(void) setReflectionNotificationTime:(NSDate *)d{
	[[UIApplication sharedApplication] cancelLocalNotification:reflectionNotification];
	
}
-(void) setSuggestionNotificationTime:(NSDate *)d{
	[[UIApplication sharedApplication] cancelLocalNotification:suggestionNotification];
}
-(void) removeReflectionTime{
	
}

-(void) removeSuggestionTime{
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 1){
		tabController.selectedIndex = 3;
	}
	
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NotificationTime *chooseNotificationTimes = [[NotificationTime alloc] init];
	chooseNotificationTimes.delegateReference = self;
	
	
	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	
	NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
	
	if(netStatus == ReachableViaWiFi){
		NSLog(@"Wifi connection is turned on!!");
	}
	else {
		NSLog(@"NO WIFI CONNECTION!!");
	}

	
	
    // Handle launching from a notification
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
		application.applicationIconBadgeNumber = 0;
		NSDictionary *ui = [localNotif userInfo];
		NSString *f = [ui objectForKey:@"Type"];
		if([f isEqualToString:@"Reflect"]){
			tabController.selectedIndex = 3;
		}
		else{
		tabController.selectedIndex = 0;
		}
		isNotFirstRun = YES;
		//[[UIApplication sharedApplication] cancelLocalNotification:localNotif];
        NSLog(@"Recieved Notification %@",localNotif);
    }
	
	
	// Get Settings/Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self setTimeMorning:(NSInteger *)[defaults integerForKey:@"time_morning"]];
	[self setTimeEvening:(NSInteger *)[defaults integerForKey:@"time_evening"]];
	NSLog(@"Time of Morning Suggestion is %@", timeMorning);
	NSLog(@"Time of Evening Suggestion is %@", timeEvening);
	if( [defaults objectForKey:@"is_not_first_run"] == NO){
		NSLog(@"First Time Executing");
		[defaults setBool:YES forKey:@"is_not_first_run"];
		[defaults synchronize];
		//[self setIsNotFirstRun:NO];
		isNotFirstRun = NO;
	}
	else{
		//[self setIsNotFirstRun:YES];
		isNotFirstRun = YES;
	}
	    
	if(!isNotFirstRun){
		//tabController.view.hidden = YES;
		NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
		
		// Get the current date
		NSDate *pickerDate = [NSDate date];
		// Break the date up into components
		NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
													   fromDate:pickerDate];
//		NSDateComponents *timeComponents = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit )
//													   fromDate:pickerDate];
		// Set up the fire time
		NSDateComponents *dateComps = [[NSDateComponents alloc] init];
		//NSDateComponents *dateComp1 = [[NSDateComponents alloc] init];
		[dateComps setDay:[dateComponents day]];
		[dateComps setMonth:[dateComponents month]];
		[dateComps setYear:[dateComponents year]];
		[dateComps setHour:10];
		[dateComps setMinute:0];
		[dateComps setSecond:0];
		
		
		NSDate *morningDate =[calendar dateFromComponents:dateComps];
		[dateComps setHour:22];
		NSDate *eveningDate = [calendar dateFromComponents:dateComps];
		//[eveningDate retain];
		//[morningDate retain];
		
		[[CoreDataManager getCoreDataManagerInstance] setMorningEveningTime:morningDate eveningDate:eveningDate];
		[dateComps release];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup" message:@"Go to the Setup Screen to update your notification times" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Setup",nil];
		[alert show];
		alert.delegate = self;
		[alert release];
		
	}

       [window addSubview:tabController.view];
	   [window makeKeyAndVisible];
	
	
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
	
	//set the selected index to the home screen (or based on the user data in the local notification
	isNotFirstRun = YES;
	NSDictionary *u = [notif userInfo];
	NSString *s = [u objectForKey:@"Type"];
	if(s != nil && [s isEqualToString:@"Reflect"]){
		tabController.selectedIndex = 2;
	}
	else{
		tabController.selectedIndex = 0;
	}
	//tabController.selectedIndex = 0;
	//app.applicationIconBadgeNumber = 0;
	//[[UIApplication sharedApplication] cancelLocalNotification:notif];
    NSLog(@"Recieved Notification %@",notif);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveContext];
	[[CoreDataManager getCoreDataManagerInstance] addLog:[NSNumber numberWithInt:7]];
	
}


- (void)saveContext {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"goslowtest2" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"goslowtest2.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
	[tabController release];
    [window release];
    [super dealloc];
}


@end

