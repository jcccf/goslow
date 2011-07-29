//
//  CoreDataManager.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Suggestion.h"
//#import "Reflection.h"
#import "ColorReflection.h"
#import "PhotoReflection.h"
#import "TextReflection.h"
#import "MorningEveningTime.h"
#import "LogScreen.h"
#import "Screen.h"
#import "goslowtest2AppDelegate.h"


@interface CoreDataManager : NSObject {
	goslowtest2AppDelegate *appDelegateReference;
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic,retain) goslowtest2AppDelegate *appDelegateReference;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

-(void)addSuggestion:(NSString *)theme picturePath:(NSString *)picturePath infoPath:(NSString *)infoPath;
-(void)addAllSuggestions;
-(void)addScreenIds;
-(void)addLog:(NSNumber *)screenId;
-(void)addScreen:(NSNumber *)screenId screenName:(NSString*) screenName;
-(void)setMorningEveningTime:(NSDate *)morningDate eveningDate:(NSDate*) eveningDate;
-(MorningEveningTime*)fetchMorningEveningTime;


-(Suggestion*)fetchSuggestion;
-(NSMutableArray*) fetchSuggestions;
-(void) randomizeSuggestions;
-(void) scheduleNotifications;

-(NSMutableArray*) fetchReflections:(NSString*) reflectionType;
-(bool)isToday:(NSDate*)refDate;
-(int)daysElapsed:(NSDate*)refDate;
-(NSString*) convertToLocalTimezone:(NSDate*) sourceDate;

-(void)addColorReflection:(NSArray *)colors;
-(void)addPhotoReflection:(NSString *)filepath;
-(void)addTextReflection:(NSString *)reflectionText;
-(NSMutableArray*)fetchLogs:(NSDate*) startDate;

-(void)saveChanges;
-(void)deleteAllObjects: (NSString *) entityDescription;
+(CoreDataManager *)getCoreDataManagerInstance;

@end