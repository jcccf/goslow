//
//  CoreDataManager.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "CoreDataManager.h"
#import "SyncManager.h"


@implementation CoreDataManager

@synthesize appDelegateReference;
@synthesize managedObjectContext;

static CoreDataManager *sharedInstance = nil;

- (id) init {
    if ( self = [super init] ) {
		// Get the Managed Object Context from the root delegate
		managedObjectContext = [(goslowtest2AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return self;
}

+(CoreDataManager *)getCoreDataManagerInstance{
	
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[CoreDataManager alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

-(void)addColorReflection:(NSArray *)colors{
	ColorReflection *newReflection = (ColorReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"ColorReflection" inManagedObjectContext:managedObjectContext];
	
	NSNumber *red = [colors objectAtIndex:(NSUInteger)0];
	NSNumber *green = [colors objectAtIndex:(NSUInteger)1];
	NSNumber *blue = [colors objectAtIndex:(NSUInteger)2];
	
	[newReflection setColorRed:red];
	[newReflection setColorGreen:green];
	[newReflection setColorBlue:blue];
	[newReflection setCreatedAt:[NSDate date]];
	
	[self saveChanges];	
	
	ImprovedLog(@"Red: %@", [newReflection colorRed]);
	ImprovedLog(@"Green: %@", [newReflection colorGreen]);
	ImprovedLog(@"Blue: %@", [newReflection colorBlue]);
	ImprovedLog(@"Created At: %@", [newReflection createdAt]);
	
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:newReflection];
	[[SyncManager getSyncManagerInstance] syncData];
	
}

-(void)addPhotoReflection:(NSString *)filepath{
	PhotoReflection *newReflection = (PhotoReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"PhotoReflection" inManagedObjectContext:managedObjectContext];
	
	[newReflection setFilepath:filepath];
	[newReflection setCreatedAt:[NSDate date]];
	
	[self saveChanges];	
	
	//ImprovedLog(@"Filepath to file: %@", [newReflection filepath]);
	
}

-(void)addTextReflection:(NSString *)reflectionText{
	TextReflection *newReflection = (TextReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"TextReflection" inManagedObjectContext:managedObjectContext];
	
	//used for table testing
	
	/*
	TextReflection *newReflectionTest = (TextReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"TextReflection" inManagedObjectContext:managedObjectContext];
	[newReflectionTest setReflectionText:@"This is a test reflection"];
	[newReflectionTest setCreatedAt:[[NSDate date] dateByAddingTimeInterval:200000]];
	
	TextReflection *newReflectionTest1 = (TextReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"TextReflection" inManagedObjectContext:managedObjectContext];
	[newReflectionTest1 setReflectionText:@"This is a test reflection"];
	[newReflectionTest1 setCreatedAt:[[NSDate date] dateByAddingTimeInterval:300000]];*/
	//end used for table

	[newReflection setReflectionText:reflectionText];
	[newReflection setCreatedAt:[NSDate date]];

	
	[self saveChanges];	
	
	ImprovedLog(@"Reflection text: %@", [newReflection reflectionText]);
	
}


-(void)addSuggestion:(NSString *)theme picturePath:(NSString *)picturePath infoPath:(NSString *)infoPath {
	Suggestion *newSuggestion = (Suggestion*)[NSEntityDescription insertNewObjectForEntityForName:@"Suggestion" inManagedObjectContext:managedObjectContext];
	[newSuggestion setTheme:theme];
	[newSuggestion setPicturePath:picturePath];
	[newSuggestion setMoreInfo:infoPath];
	
	[self saveChanges];
	
}

-(void)addLog:(NSNumber *)screenId {
	LogScreen *newLog = (LogScreen*)[NSEntityDescription insertNewObjectForEntityForName:@"LogScreen" inManagedObjectContext:managedObjectContext];
	[newLog setScreenId:screenId];
	[newLog setCreatedAt:[NSDate date]];
	
	[self saveChanges];	
	
	ImprovedLog(@"Screen %@ accessed at %@", [newLog screenId], [newLog createdAt]);
	
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:newLog];
	[[SyncManager getSyncManagerInstance] syncData];
}

-(void)addScreen:(NSNumber *)screenId screenName:(NSString*) screenName {
	Screen *newScreen = (Screen*)[NSEntityDescription insertNewObjectForEntityForName:@"Screen" inManagedObjectContext:managedObjectContext];
	[newScreen setScreenId:screenId];
	[newScreen setName:screenName];
	
	[self saveChanges];	
	
	ImprovedLog(@"Screen %@ has name: %@", [newScreen screenId], [newScreen name]);
	
}

-(bool)isToday:(NSDate*)refDate {

	NSString *date = [[refDate description]substringToIndex: 10];
	NSString *nowDate = [[[NSDate date]description]substringToIndex: 10];
	
	// same day
	if([date isEqualToString: nowDate]) {
		// your code
		return YES;
	}
	else {
		return NO;
	}
}

-(int)daysElapsed:(NSDate*)refDate {
	
	NSString *refDay = [[refDate description]substringToIndex: 10];
	NSString *nowDay = [[[NSDate date]description]substringToIndex: 10];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
	
    NSDate *refDateAtMidnight = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@ %@", refDay, @"00:00:00", @"UTC"]];
	NSDate *nowDateAtMidnight = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@ %@", nowDay, @"00:00:00", @"UTC"]];
	
	[dateFormatter release];
	
	NSTimeInterval timeInterval = [refDateAtMidnight timeIntervalSinceDate:nowDateAtMidnight];
	
	double seconds = (double) timeInterval;
	double days = seconds / (60*60*24);
	int daysElapsed = (int) days * -1;

	return daysElapsed;
}

-(NSString*) convertToLocalTimezone:(NSDate*) sourceDate {
	
	//NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
	[formatter setTimeZone:destinationTimeZone];
	
	NSString* destinationString = [formatter stringFromDate:sourceDate];
	ImprovedLog(@"Converted: %@", destinationString);
	
//	NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
//	NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
//	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
//	
//	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
//	destinationDate = [formatter dateFromString:destinationDate];
	
	return destinationString;
	
}

-(void)addAllSuggestions{
	[self deleteAllObjects:@"Suggestion"];
	
    NSMutableArray *textPicturePaths = [NSMutableArray array];
    NSMutableArray* picturePaths = [NSMutableArray array];
    NSMutableArray* themes = [NSMutableArray array];
    
    // Iterate through all text files in /suggestions folder
    NSString* suggestionsRoot = [NSString stringWithFormat:@"%@/suggestions", [[NSBundle mainBundle] bundlePath]];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:suggestionsRoot error:nil];
    NSArray *textFiles = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.txt'"]];
    NSString* separator = @"<!--REST-->";
    int separatorLength = [separator length];
    for (NSString* pPath in textFiles) {
        //Look at each text file, assume the first line is the theme, the rest is about the suggestion
        NSString* fullPath = [NSString stringWithFormat:@"%@/%@", suggestionsRoot, pPath];
        NSString* textFileText = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        int nlLocation = [textFileText rangeOfString:separator].location;
        NSString* title = [textFileText substringToIndex:nlLocation]; // Get the title which is everything before the separator
        NSString* rest = [textFileText substringFromIndex:nlLocation+separatorLength]; // Get the suggestion text which is everything after
        NSString* imageFile = [NSString stringWithFormat:@"%@.jpg", [pPath substringToIndex:[pPath rangeOfString:@"." options:NSBackwardsSearch].location]];
        //Add them to the appropriate arrays
        [themes addObject:title];
        [picturePaths addObject:imageFile];
        [textPicturePaths addObject:rest];
        ImprovedLog(@"Added %@ with Image File %@...", title, imageFile);
    }
	
	int arrayCount = [picturePaths count];
	
	for (int i = 0; i < arrayCount; i++) {
		NSString* theme = [themes objectAtIndex:i];
		NSString* picturePath = [picturePaths objectAtIndex:i];
		NSString* infoPath = [textPicturePaths objectAtIndex:i];
		[self addSuggestion:theme picturePath:picturePath infoPath:infoPath];
	}
	
	NSMutableArray *suggestions = [self fetchSuggestions];
	
	NSUInteger count = [suggestions count];

	for (NSUInteger i = 0; i < count; ++i) {
		// Select a random element between i and end of array to swap with.
		int nElements = count - i;
		int n = (arc4random() % nElements) + i;
		[suggestions exchangeObjectAtIndex:i withObjectAtIndex:n];
	}		
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	
	//Then reschedule each suggestion's nextSeen field	
	for (int i = 0; i < [suggestions count]; i++) {
		
		[offset setDay:i];
		NSDate* nextSeen = [calendar dateByAddingComponents:offset toDate:[NSDate date] options:0];
		Suggestion *suggestion = [suggestions objectAtIndex:i];
		[suggestion setNextSeen:nextSeen];
		[self saveChanges];
		
	}
	
	[offset release];
	
}

-(void)addScreenIds{
	[self deleteAllObjects:@"LogScreen"];
	[self deleteAllObjects:@"Screen"];
	
	NSArray *screenIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2], [NSNumber numberWithInt:3], [NSNumber numberWithInt:4], [NSNumber numberWithInt:5], [NSNumber numberWithInt:6],[NSNumber numberWithInt:7], [NSNumber numberWithInt:8],[NSNumber numberWithInt:9],[NSNumber numberWithInt:10],nil];
	
	NSString *screenNameString = @"Suggestion,Diary,Reflection,ColorReflection,TextReflection,PhotoReflection,Close,SaveColorReflection,SaveTextReflection,SavePhotoReflection";
	NSArray *screenNames = [screenNameString componentsSeparatedByString:@","];
	
	int arrayCount = [screenIds count];
	
	for(int i = 0; i < arrayCount; i++){
		NSNumber* screenId = [screenIds objectAtIndex:i];
		NSString* screenName = [screenNames objectAtIndex:i];
		
		[self addScreen:screenId screenName:screenName];
		ImprovedLog(@"%@: %@", screenId, screenName);
	}
	
}

-(void)setMorningEveningTime:(NSDate *)morningDate eveningDate:(NSDate*) eveningDate {
	
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MorningEveningTime" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	[request release];
	
	if ([mutableFetchResults count] == 0) {
		MorningEveningTime *newTime = (MorningEveningTime*)[NSEntityDescription insertNewObjectForEntityForName:@"MorningEveningTime" inManagedObjectContext:managedObjectContext];
	
		[newTime setMorningDate:morningDate];
		[newTime setEveningDate:eveningDate];
	
		[self saveChanges];	
		
		ImprovedLog(@"Created new time");
		ImprovedLog(@"Morning date: %@", [newTime morningDate]);
		ImprovedLog(@"Evening date: %@", [newTime eveningDate]);
		
	} else {
		MorningEveningTime *oldTime = (MorningEveningTime*)[mutableFetchResults objectAtIndex:0];
		[oldTime setMorningDate:morningDate];
		[oldTime setEveningDate:eveningDate];
		
		[self saveChanges];
		
		ImprovedLog(@"Changed old time");
		ImprovedLog(@"Morning date: %@", [oldTime morningDate]);
		ImprovedLog(@"Evening date: %@", [oldTime eveningDate]);
	}
	
	
}

// record that user fetched the date in the method
// look to NSPredicate for SQL-like queries
-(Suggestion*) fetchSuggestion {
	
	// Fetch Suggestions From Data Store
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Suggestion" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Set Sort Descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nextSeen" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	Suggestion *suggestion = (Suggestion*)[mutableFetchResults objectAtIndex:(arc4random() % [mutableFetchResults count])];
	
	bool mustReschedule = YES;
	
	for (int i = 0; i < [mutableFetchResults count]; i++) {
		Suggestion *s = (Suggestion*)[mutableFetchResults objectAtIndex:i];
		NSDate *scheduledDate = [s nextSeen];
		
		if ([self isToday:scheduledDate]) {
			mustReschedule = NO;
			break;
		}
	}
	
	if (mustReschedule) {
		[self randomizeSuggestions];
	}
	
	[request release];
	
	// Send to Sync Manager
	// Uncomment the below when fixed.
	NSArray *sugarRay = [NSArray arrayWithObjects:[suggestion theme], [NSDate date], nil];
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:sugarRay];
	[[SyncManager getSyncManagerInstance] syncData];
	
	//Set last seen to today's date
	[suggestion setLastSeen:[NSDate date]];
	ImprovedLog(@"Date: %@", [suggestion lastSeen]);
	[self saveChanges];	
	
	return suggestion;	
	
	
}

-(NSMutableArray*) fetchSuggestions {
	
	// Fetch Suggestions From Data Store
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Suggestion" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Set Sort Descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nextSeen" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	[request release];
	
	return mutableFetchResults;
	
}

-(void) randomizeSuggestions {
	
	// Fetch Suggestions From Data Store
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Suggestion" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Set Sort Descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nextSeen" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	[request release];
	
	NSDate *latestDate = [[mutableFetchResults objectAtIndex:([mutableFetchResults count]-1)] nextSeen];
	
	NSUInteger count = [mutableFetchResults count];
	NSUInteger increment = count/3;
	
	// Shuffle the array in three chunks
	for (int j = 0; j < count; j+=increment) {
		for (NSUInteger i = j; i < j+increment; ++i) {
			// Select a random element between i and end of array to swap with.
			int nElements = j+increment - i;
			int n = (arc4random() % nElements) + i;
			[mutableFetchResults exchangeObjectAtIndex:i withObjectAtIndex:n];
		}		
		
	}
	
	//Then reschedule each suggestion's nextSeen field
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	
	for (int i = 0; i < [mutableFetchResults count]; i++) {
		
		[offset setDay:i+1];
		NSDate *notificationDate = [calendar dateByAddingComponents:offset toDate:latestDate options:0];
		Suggestion *suggestion = [mutableFetchResults objectAtIndex:i];
		[suggestion setNextSeen:notificationDate];
		[self saveChanges];
		
		ImprovedLog(@"Theme: %@", [suggestion theme]);
		ImprovedLog(@"Next Seen: %@", [suggestion nextSeen]);
		ImprovedLog(@"Last Seen: %@", [suggestion lastSeen]);
		
	}
	
	[offset release];
	
	[self scheduleNotifications];
	
}

-(void) scheduleNotifications {
	//[self.view removeFromSuperview];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	NSMutableArray *suggestions = [[CoreDataManager getCoreDataManagerInstance] fetchSuggestions];
	MorningEveningTime *times = [[CoreDataManager getCoreDataManagerInstance] fetchMorningEveningTime];
	NSDate *morningDate = [times morningDate];
	NSDate *eveningDate = [times eveningDate];
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *offset = [[NSDateComponents alloc] init];
	
	for (int i = 0; i < [suggestions count]; i++) {
		
		Suggestion *suggestion = [suggestions objectAtIndex:i];
		NSTimeInterval diff = [[suggestion nextSeen] timeIntervalSinceDate:morningDate];
		
		int days = (int) diff / (60*60*24);
		ImprovedLog(@"days since %@: %i", morningDate, days);
		
		[offset setDay:days];
		//[offset setMinute:i];	
		NSDate *notificationDate = [calendar dateByAddingComponents:offset toDate:morningDate options:0];
		//NSDate *notificationDate = [calendar dateByAddingComponents:offset toDate:[NSDate date] options:0];
		
		UILocalNotification *localNotifMorning = [[UILocalNotification alloc] init];
		if (localNotifMorning == nil)
			return;
		
		localNotifMorning.fireDate = notificationDate;
		localNotifMorning.timeZone = [NSTimeZone defaultTimeZone];
		//localNotifMorning.repeatInterval = NSMinuteCalendarUnit;
		
		localNotifMorning.alertBody = [NSString stringWithFormat:@"Today's Suggestion: %@", [suggestion theme]];
		localNotifMorning.alertAction = @"See More";
		
		// Schedule ONLY for notifications happening in the future
		// Notifications scheduled for the past fire immediately
		if ([[localNotifMorning fireDate] timeIntervalSinceNow] > 0) {
			ImprovedLog(@"Scheduling %@", [suggestion theme]);
			[[UIApplication sharedApplication] scheduleLocalNotification:localNotifMorning];
		}
		
		[localNotifMorning release];
		
		
	}
	
	[offset release];
	
	//UILocalNotification *localNotifMorning = [[UILocalNotification alloc] init];
	UILocalNotification *localNotifEvening = [[UILocalNotification alloc] init];
	//    if (localNotifMorning == nil)
	//        return;
	if (localNotifEvening == nil)
        return;
	
	localNotifEvening.fireDate = eveningDate;
	//localNotifMorning.fireDate = morningDate;
	
	localNotifEvening.timeZone = [NSTimeZone defaultTimeZone];
	//localNotifMorning.timeZone = [NSTimeZone defaultTimeZone];
	
	localNotifEvening.repeatInterval = NSDayCalendarUnit;
	//	localNotifMorning.repeatInterval = NSDayCalendarUnit;
	
	//	localNotifMorning.alertBody = @"Would you like a suggestion?";
	//	localNotifMorning.alertAction = @"See More";
	localNotifEvening.alertBody = @"How was your day?";
	localNotifEvening.alertAction = @"Reflect";
	NSString *key = [NSString stringWithString:@"Type"];
	NSString *val = [NSString stringWithString:@"Reflect"];
	localNotifEvening.userInfo = [NSDictionary dictionaryWithObject:val forKey:key];
	
	
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotifEvening];
	//[[UIApplication sharedApplication] scheduleLocalNotification:localNotifMorning];
	
	[localNotifEvening release];
	//[localNotifMorning release];
	
	/*localNotif.fireDate = [itemDate dateByAddingTimeInterval:1];
	 
	 //1 day repeat interval
	 localNotif.repeatInterval = NSDayCalendarUnit;
	 // localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:20];
	 localNotif.timeZone = [NSTimeZone defaultTimeZone];
	 
	 // Notification details
	 localNotif.alertBody = @"You should reflect";
	 // Set the action button
	 localNotif.alertAction = @"Reflect";
	 
	 localNotif.soundName = UILocalNotificationDefaultSoundName;
	 localNotif.applicationIconBadgeNumber = 1;
	 
	 // Specify custom data for the notification
	 NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
	 localNotif.userInfo = infoDict;
	 
	 // Schedule the notification
	 [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
	 [localNotif release];*/
	
}


-(NSMutableArray*) fetchReflections:(NSString*) reflectionType {
	
	// Fetch Reflections From Data Store
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:reflectionType inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Set Sort Descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	[request release];
	
	return mutableFetchResults;
	
}

-(NSMutableArray*)fetchLogs:(NSDate*) startDate {

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogScreen" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Set Sort Descriptors
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastSeen > %@)", startDate];
	[request setPredicate:predicate];
	
	[request setSortDescriptors:sortDescriptors];
	[sortDescriptors release];
	[sortDescriptor release];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	[request release];
	
	return mutableFetchResults;
	
}

-(MorningEveningTime*)fetchMorningEveningTime {
	// Create Request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MorningEveningTime" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	// Fetch Results
	NSError *error;
	NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	
	[request release];
	
	if ([mutableFetchResults count] == 0) {
		return nil;
		
	} else {
		MorningEveningTime *oldTime = (MorningEveningTime*)[mutableFetchResults objectAtIndex:0];
		return oldTime;
	}
	
}


-(void)saveChanges {
	//Save to Core Data
	NSError *saveError;
	if (![managedObjectContext save:&saveError]) {
		ImprovedLog(@"Saving changes failed: %@", saveError);
	} else {
		// The changes to suggestion have been persisted.
		ImprovedLog(@"Changes have been saved.");
	}
	
	[NSError release];
	
}

//Deletes all objects in the sqllite database
- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
	
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        ImprovedLog(@"%@ object deleted",entityDescription);
    }
    if (![managedObjectContext save:&error]) {
        ImprovedLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
	
}

- (void) dealloc {
    [super dealloc];
}

@end
