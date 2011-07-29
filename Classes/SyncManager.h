//
//  SyncManager.h
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reflection.h"

@class Reachability;

@interface SyncManager : NSObject {
	int userId;
	NSMutableArray *bufferedReflections;
	Reachability* wifiReach;
	NSLock* urLock;
}

@property (nonatomic,retain) NSMutableArray *bufferedReflections;
@property (nonatomic,retain) NSLock *urLock;

- (void) setUserId:(int)uid;
- (void) sendTextReflection:(NSString*)text;
- (void) sendPhotoReflection:(UIImage*)image;
- (void) sendColorReflectionWithRed:(NSNumber*)r andGreen:(NSNumber*)g andBlue:(NSNumber*)b;
- (void) sendDailySuggestion:(NSString*)theme andTime:(NSString*)timestamp;
- (void) sendLogScreen:(int)screen_id andTime:(NSString*)timestamp;

- (void) syncData;

- (void) cleanup: (NSString *) output;

+(SyncManager*) getSyncManagerInstance;
@end
