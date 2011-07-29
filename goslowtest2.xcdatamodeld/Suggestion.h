//
//  Suggestion.h
//  goslowtest2
//
//  Created by Justin Cheng on 10/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Suggestion :  NSManagedObject {
}

@property (nonatomic, retain) NSString * moreInfo;
@property (nonatomic, retain) NSString * picturePath;
@property (nonatomic, retain) NSString * theme;
@property (nonatomic, retain) NSDate *lastSeen;
@property (nonatomic, retain) NSDate *nextSeen;

@end



