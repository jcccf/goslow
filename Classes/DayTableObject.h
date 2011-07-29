//
//  DayTableObject.h
//  goslowtest2
//
//  Created by Gregory Thomas on 11/23/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reflection;

@interface DayTableObject : NSObject {

	NSMutableArray *reflections;
	NSString *dayStringRepresentation;
}


@property(nonatomic,retain) NSMutableArray *reflections;
@property(nonatomic,retain) NSString *dayStringRepresentation;

-(id)initWithDay:(NSString*)day andReflections:(NSMutableArray*)refl;

-(void)addReflection:(Reflection *)r;
@end
