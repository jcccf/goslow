//
//  ReflectionTableManager.h
//  goslowtest2
//
//  Created by Gregory Thomas on 11/23/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ReflectionTableManager : NSObject {

	//this dictionary has key NSString (substring to first 10)
	//Value is DayTableObject (a representation of a days worth of reflections)
	NSMutableDictionary *dayToTableRepDict;
}


@property(nonatomic,retain) NSMutableDictionary *dayToTableRepDict;


@end
