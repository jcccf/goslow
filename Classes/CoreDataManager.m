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
	
	NSLog(@"Red: %@", [newReflection colorRed]);
	NSLog(@"Green: %@", [newReflection colorGreen]);
	NSLog(@"Blue: %@", [newReflection colorBlue]);
	NSLog(@"Created At: %@", [newReflection createdAt]);
	
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:newReflection];
	[[SyncManager getSyncManagerInstance] syncData];
	
}

-(void)addPhotoReflection:(NSString *)filepath{
	PhotoReflection *newReflection = (PhotoReflection*)[NSEntityDescription insertNewObjectForEntityForName:@"PhotoReflection" inManagedObjectContext:managedObjectContext];
	
	[newReflection setFilepath:filepath];
	[newReflection setCreatedAt:[NSDate date]];
	
	[self saveChanges];	
	
	//NSLog(@"Filepath to file: %@", [newReflection filepath]);
	
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
	
	NSLog(@"Reflection text: %@", [newReflection reflectionText]);
	
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
	
	NSLog(@"Screen %@ accessed at %@", [newLog screenId], [newLog createdAt]);
	
	[[[SyncManager getSyncManagerInstance] bufferedReflections] addObject:newLog];
	[[SyncManager getSyncManagerInstance] syncData];
}

-(void)addScreen:(NSNumber *)screenId screenName:(NSString*) screenName {
	Screen *newScreen = (Screen*)[NSEntityDescription insertNewObjectForEntityForName:@"Screen" inManagedObjectContext:managedObjectContext];
	[newScreen setScreenId:screenId];
	[newScreen setName:screenName];
	
	[self saveChanges];	
	
	NSLog(@"Screen %@ has name: %@", [newScreen screenId], [newScreen name]);
	
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
	NSLog(@"Converted: %@", destinationString);
	
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
	
	//NSString *textPaths = @"<b>Deep breathing</b> can reduce anxiety and disrupt repetitive or negative thoughts by focusing awareness on the present moment. Changing your breathing can shift your mood and perspective. <i>Try taking a deep breath in through the nose for 3 seconds... hold for 2 seconds... breathe out through the mouth for 6 seconds...</i>,back of Choose Consciously.jpg,backof Connect with Nature.jpg,backof connect with others.jpg,backof Control worry.jpg,backof Eat Well.jpg,backof Exercise.jpg,backof Express Gratitude.jpg,backof Get more sleep.jpg,backof Grow from mistakes.jpg,backof Laughter.jpg,backof Music.jpg,backof Meditation.jpg,backof Play.jpg,backof Powernap.jpg,backof reflect.jpg,backof Relax your Body.jpg,backof Think Positively.jpg,backof Thoughts matter.jpg,backof Use Resources.jpg,backof Visualization.jpg";
	NSMutableArray *textPicturePaths = [NSMutableArray array];
	
	[textPicturePaths addObject:@"<b>Deep breathing</b> can reduce anxiety and disrupt repetitive or negative thoughts by focusing awareness on the present moment. Changing your breathing can shift your mood and perspective. <i>Try taking a deep breath in through the nose for 3 seconds... hold for 2 seconds... breathe out through the mouth for 6 seconds...</i>"];
	[textPicturePaths addObject:@"<b>Choose consciously.</b> Making conscious choices based on your personal values and priorities means living with intention. It can increase your power over how you spend your time, respond to others, and react to situations.<br /><b>Try this:</b> <i>Think of one thing you want to accomplish today. Focus your mind on this intention. Notice the increased sense of control and clarity on how to proceed.</i>"];
	[textPicturePaths addObject:@"<b>Nature is in perfect balance.</b> When you view it or immerse yourself in it, you can connect with your own natural equilibrium. Nature can remind you to keep life in perspective, and help you feel renewed and focused. <br /><b>Try this:</b><i> Go for a walk, take in the view outside your window, watch a squirrel, or listen to the wind. Notice how it influences your thoughts and overall mood.</i>"];
	[textPicturePaths addObject:@"<b>Connecting with people</b> who respect and care about you, and offer support rather than judgment, is one of the best ways to restore balance and renew your hope (or “energy”). Studies show that people who have close and trusting relationships feel less stressed, anxious, and depressed.<br /><b>Try this</b>: <i>Take time every day to share a meal, walk to class, see a film, or shoot hoops with a good friend.</i>"];
	[textPicturePaths addObject:@"<b>Control worry.</b> Sometimes worry is a symptom that something needs your attention. Focusing on the source of the worry can help you explore its seriousness and take action. Other times, the source of worry is beyond your control. If such worries create repetitive thoughts or anxiety for you, learning how to “let go” can help restore peace of mind. <br /><b>Try this:</b> <i>Worried about things you cannot change? Let go of the source of the worry. Instead, take action where you can: focus on responding in a healthy way. Breathe. Move. Laugh.</i>"];
	[textPicturePaths addObject:@"<b>Eat well.</b> Quality food, eaten at regular intervals, provides the fuel your body and mind need to be productive throughout the day. It also provides the energy needed to buffer life’s daily stressors. <i>Choose a variety of food - colors, textures, tastes - at meals. Combine foods (e.g. an apple and a piece of cheese) to create a high-energy snack. Take time to enjoy your food: notice the flavor and feel of each bite.</i>"];
	[textPicturePaths addObject:@"<b>Exercise</b> is a healthy way to release pent-up energy, anger, or anxiety. Just 30 minutes of moderate exercise releases endorphins, the body’s natural mood enhancers. Any physical movement can help relieve stress. Try walking, running, hiking, dancing, swimming, skating, shooting hoops, or working out at the gym."];
	[textPicturePaths addObject:@"<b>Express Gratitude.</b> Gratitude is an attitude you can choose, even when things are difficult. Giving and receiving appreciation reminds us that we are not alone and belong to something bigger than ourselves.<br /><b>Try this:</b> <i>Make a list of people and things you are grateful for today. Add to the list over time. Express your thanks daily. Notice how it makes you feel.</i>"];
	[textPicturePaths addObject:@"<b>Get more sleep.</b> The benefits will affect nearly every area of your life. Sleep helps repair the body, helps you cope better with stress, and improves memory and learning. After a good night’s sleep your thoughts are clearer, your reactions faster, and your emotions less fragile.<br /><b>Try this:</b> <i>Set your bedtime 15-30 minutes earlier. Gradually, add more minutes until you are getting at least eight hours each night.<i>"];
	[textPicturePaths addObject:@"<b>Grow from mistakes.</b> Successful people say what they learned from their mistakes enabled them to succeed. Give yourself permission to be imperfect so you can open yourself to learning. “Failure” doesn’t mean you aren’t doing your best. It may mean it’s time to evaluate what got in the way of a better result.<br /><b>Try this:</b> <i>Use self-examination or ask for feedback on where to focus your efforts next time to create a different outcome.</i>"];
	[textPicturePaths addObject:@"<b>Laughter</b> jolts us out of our usual state of mind and can eliminate negative feelings. As a result, humor can be a powerful antidote to burn-out. Hearty belly-laughs exercise muscles, stimulate circulation, decrease stress hormones, and increase your immune system’s defenses, making laughter one of the most beneficial stress reduction techniques you can practice."];
	[textPicturePaths addObject:@"<b>Music</b> can energize or relax you. Studies show it can lower blood pressure and respiration, creating a calming effect. <i>Be conscious of how music makes you feel. Choose what you need at the moment (e.g. to lighten a heavy mood; to help you relax and fall asleep).</i> Have fun discovering new music: attend performances; make your own (sing, drum, etc.). Enjoy sharing it all with your friends."];
	[textPicturePaths addObject:@"<b>Meditation</b> is the process of tuning out the world and turning your attention inward. Focus your attention on your breath, a word or phrase, or an image. <i>Observe without judgment any distracting thoughts that arise as you “tune in;” release them as you exhale. Return your attention inward.</i> Once you acquire the skill, mindfulness meditation can be done anywhere, for a few minutes or longer when possible."];
	[textPicturePaths addObject:@"<b>Play!</b> Enjoy a pleasurable, no-pressure activity. Being “child-like\" (different from “child<u>ish</u>”) allows you to explore, to experience your feelings in the moment, to release your tension in a creative way, and to rebound from disappointments with greater ease. <i>Whether it’s finger painting, jumping in leaves, or reading a book “just for fun,” take time to experience the joy of play every day.</i>"];
	[textPicturePaths addObject:@"<b>Power naps</b>, most effective in the afternoon, can make you more alert, reduce stress, and boost cognitive functioning. <i>Find a suitable place to relax, take a few deep breaths, and focus your attention on sleep. Enjoy giving your body this time to recharge.</i> To avoid feeling groggy afterward, limit your power nap to 20-30 minutes."];
	[textPicturePaths addObject:@"<b>Self-reflection</b> allows you to re-connect with your thoughts, feelings, and needs. It can help you “take stock” of attitudes and behaviors you want to keep, and those you hope to change. Making time to reflect can reduce stress by keeping you centered on what is most important for you.<br /><b>Try this</b>: <i>Keep a personal journal as a tool of self-discovery, to explore ideas, and set intentions.</i>"];
	[textPicturePaths addObject:@"<b>Progressive muscle relaxation</b> systematically relieves bodily tension and helps you feel more relaxed within minutes. <i>Starting with your toes and working your way up to your head, slowly tighten… hold… and then relax your various muscle groups (e.g. feet, legs, abdomen, buttocks, shoulders, arms, hands, face). As you release, think to yourself “these muscles are now relaxed.”</i> You may notice a feeling of heaviness as tension leaves your body."];
	[textPicturePaths addObject:@"<b>Think positively.</b> A healthy dose of optimism helps you make the best of stressful situations and increases your chance of success. Positive thinking allows you to hold on to positive feelings about yourself in times of disappointment, and to bounce back more quickly. <br /><b>Try this:</b><i> Remind yourself each day of one of your strengths. How can you use these to overcome adversity and accomplish goals?</i>"];
	[textPicturePaths addObject:@"<b>Thoughts matter</b> when it comes to stress. Every thought, every perception creates feelings that can either activate the stress response or the relaxation response. By becoming more aware of your thought patterns, you can identify what triggers your responses. Many strategies can help you counter stressful thoughts and maintain emotional balance."];
	[textPicturePaths addObject:@"<b>Use Resources.</b> Hundreds of people across campus can offer information, support, and encouragement when you encounter challenges. Reaching out to others can save time, reduce frustration, and provide options or perspective you may not have considered. Everyone needs a little support once in a while.<br /><b>Try this:</b> <i>Access resources early, before an issue becomes problematic.</i>"];
	[textPicturePaths addObject:@"<b>Visualization:</b> By mentally rehearing a task you want to master, you can achieve many of the same benefits you might from actual, physical practice. <i>Close your eyes and take a few deep breaths. Imagine yourself acting the task (e.g. taking an exam, having an important conversation). Now, focus on how your success feels (jazzed, relieved, satisfied, smart, etc.). Stay with that feeling for a while.</i>"];
	
	
	NSString *picturePathsString = @"breathe.jpg,choose_consciously.jpg,connect_with_nature.jpg,connect_with_others.jpg,control_worry.jpg,eat_well.jpg,exercise.jpg,express_gratitude.jpg,get_more_sleep.jpg,grow_from_mistakes.jpg,laugh.jpg,listen_to_music.jpg,meditate.jpg,play.jpg,power_nap.jpg,reflect.jpg,relax_your_body.jpg,think_positively.jpg,thoughts_matter.jpg,use_resources.jpg,visualize.jpg";
	
	NSArray *picturePaths = [picturePathsString componentsSeparatedByString:@","];
	
	NSString *themeString = @"Breathe,Choose Consciously,Connect With Nature,Connect With Others,Control Worry,Eat Well,Exercise,Express Gratitude,Get More Sleep,Grow From Mistakes,Laugh,Listen To Music,Meditate,Play,Power Nap,Reflect,Relax Your Body,Think Positively,Thoughts Matter,Use Resources,Visualize";
	
	NSArray *themes = [themeString componentsSeparatedByString:@","];	
	int arrayCount = [picturePaths count];
	
	for(int i = 0; i < arrayCount; i++){
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
		NSLog(@"%@: %@", screenId, screenName);
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
		
		NSLog(@"Created new time");
		NSLog(@"Morning date: %@", [newTime morningDate]);
		NSLog(@"Evening date: %@", [newTime eveningDate]);
		
	} else {
		MorningEveningTime *oldTime = (MorningEveningTime*)[mutableFetchResults objectAtIndex:0];
		[oldTime setMorningDate:morningDate];
		[oldTime setEveningDate:eveningDate];
		
		[self saveChanges];
		
		NSLog(@"Changed old time");
		NSLog(@"Morning date: %@", [oldTime morningDate]);
		NSLog(@"Evening date: %@", [oldTime eveningDate]);
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
	NSLog(@"Date: %@", [suggestion lastSeen]);
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
		
		NSLog(@"Theme: %@", [suggestion theme]);
		NSLog(@"Next Seen: %@", [suggestion nextSeen]);
		NSLog(@"Last Seen: %@", [suggestion lastSeen]);
		
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
		NSLog(@"days since %@: %i", morningDate, days);
		
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
			NSLog(@"Scheduling %@", [suggestion theme]);
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
		NSLog(@"Saving changes failed: %@", saveError);
	} else {
		// The changes to suggestion have been persisted.
		NSLog(@"Changes have been saved.");
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
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
	
}

- (void) dealloc {
    [super dealloc];
}

@end
