//
//  MorningEveningTime.h
//  goslowtest2
//
//  Created by Kevin Tse on 11/21/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MorningEveningTime :  NSManagedObject {
	
}

@property (nonatomic, retain) NSDate *morningDate;
@property (nonatomic, retain) NSDate *eveningDate;

@end
