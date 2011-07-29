//
//  SyncManagerConnectionDelegate.h
//  goslowtest2
//
//  Created by Justin Cheng on 11/16/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncManagerConnectionDelegate : NSObject {
	NSString *syncType;
	NSMutableURLRequest *urlRequest;
	NSLock* lock;
}

-(SyncManagerConnectionDelegate*) set:(NSMutableURLRequest*) urlRequest withLock:(NSLock*) lock withType:(NSString*) syncType;

@end