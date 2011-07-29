//
//  SyncManagerConnectionDelegate.m
//  goslowtest2
//
//  Created by Justin Cheng on 11/16/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "SyncManagerConnectionDelegate.h"


@implementation SyncManagerConnectionDelegate

-(SyncManagerConnectionDelegate*) set:(NSMutableURLRequest*) ur withLock:(NSLock*) l withType:(NSString*) st{
	self = [super init];
	if (self) {
		urlRequest = ur;
		syncType = st;
		lock = l;
		return self;
	}
	else {
		return nil;
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@ Received response...", syncType);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *outstring = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", [NSString stringWithFormat: @"%@ success: %@", syncType, outstring]);
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
	
	NSLog(@"A connection error happened!");
	
	assert(urlRequest != nil);
	
	// Add to the pending urlRequest list
	NSLog(@"Trying to lock");
	[lock lock];
	NSLog(@"Trying to lock2");
	NSMutableArray* ar = [[NSMutableArray alloc] init];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSData *objectsData = [userDefaults objectForKey:@"savedUrlRequests"];
	NSArray *objects = [NSKeyedUnarchiver unarchiveObjectWithData:objectsData];
	NSLog(@"Trying to lock3");
	if(objects != nil){
		[ar removeObjectsInArray:objects];
		[ar addObjectsFromArray:objects];
	}
	NSLog(@"Trying to lock4");
	[ar addObject:urlRequest];
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:ar] forKey:@"savedUrlRequests"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"Trying to lock5");
	[lock unlock];
	NSLog(@"%@ failed and was saved to the pending urlRequest list", syncType);
    NSLog(@"%@ failed with error - %@", syncType, [error localizedDescription]);
	
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%@ upload succeeded!", syncType);
    [connection release];
}

- (void)dealloc{
	[urlRequest release];
	[syncType release];
	[super dealloc];
}

@end
