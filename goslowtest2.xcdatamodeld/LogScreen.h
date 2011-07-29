//
//  LogScreen.h
//  goslowtest2
//
//  Created by Kevin Tse on 11/2/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LogScreen : NSManagedObject {
	
}

@property (nonatomic,retain) NSNumber *screenId;
@property (nonatomic,retain) NSDate *createdAt;
@end
