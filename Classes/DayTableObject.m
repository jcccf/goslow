//
//  DayTableObject.m
//  goslowtest2
//
//  Created by Gregory Thomas on 11/23/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "DayTableObject.h"

#import "CoreDataManager.h"

#import "Reflection.h"


@implementation DayTableObject

@synthesize reflections, dayStringRepresentation;


-(id)initWithDay:(NSString *)day andReflections:(NSMutableArray*)refl{

	reflections = refl;
	dayStringRepresentation = day;
	
	return self;
}

-(void)addReflection:(Reflection*)r{

	if(reflections == nil)
		reflections = [[NSMutableArray alloc] init];
	[reflections addObject:r];
	[r retain];
	
}

@end
