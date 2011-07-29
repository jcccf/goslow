//
//  ReflectionTableManager.m
//  goslowtest2
//
//  Created by Gregory Thomas on 11/23/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "ReflectionTableManager.h"

#import "CoreDataManager.h"

#import "DayTableObject.h"


@implementation ReflectionTableManager

@synthesize dayToTableRepDict;


-(id)init{
	
	dayToTableRepDict = [[NSMutableDictionary alloc] init];
		
	CoreDataManager *data = [CoreDataManager getCoreDataManagerInstance];
	
	NSMutableArray *allReflections = [data fetchReflections:@"Reflection"];
	
	for(Reflection *r in allReflections){
		
//		NSString *subDate = [[[r createdAt] description] substringToIndex:10];
		NSString *subDate = [[[CoreDataManager getCoreDataManagerInstance] convertToLocalTimezone: [r createdAt]] substringToIndex:10];
		
		//If this date is not already in the table
		if([dayToTableRepDict objectForKey:subDate] == nil){
			
			DayTableObject *d = [[DayTableObject alloc] init];
			
			d.dayStringRepresentation = subDate;
			
			[d addReflection:r];
			
			[dayToTableRepDict setObject:d forKey:subDate];
			
		}
		//date is in table, add it to its reflection array
		else{
			DayTableObject *d = [dayToTableRepDict objectForKey:subDate];
			
			[d addReflection:r];
			
		}
	}
	


	return self;
}

@end
