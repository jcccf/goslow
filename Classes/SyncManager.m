//
//  SyncManager.m
//  goslowtest2
//
//  Created by Gregory Thomas on 10/18/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "SyncManager.h"
#import "SyncManagerConnectionDelegate.h"
#import "Reachability.h"
#import "LogScreen.h"
#import "ColorReflection.h"

// Posting constants
#define NOTIFY_AND_LEAVE(X) {[self cleanup:X]; return;}
#define DATA(X)	[X dataUsingEncoding:NSUTF8StringEncoding]
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@implementation SyncManager

static SyncManager *sharedInstance = nil;

@synthesize bufferedReflections, urLock;

+(SyncManager*)getSyncManagerInstance{
	@synchronized(self){
		if(sharedInstance == nil){
			sharedInstance = [[self alloc] init];
			sharedInstance.bufferedReflections = [[[NSMutableArray alloc] init] retain];
			sharedInstance.urLock = [[NSLock alloc] init];
		}
	}
	return sharedInstance;
}

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) 
		{
			// handle image data
			NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:value];
		}
		else 
		{
			// all non-image fields assumed to be strings
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:DATA(value)];
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    return result;
}

-(void)setUserId:(int)uid{
	userId = uid; //TODO Does this work?
}

-(NSString*)getUserIdAsString{
	assert(userId != 0); // Have you set the userId??
	return [NSString stringWithFormat: @"%d", userId];
}

-(void) sendTextReflection:(NSString *)text{
	NSLog(@"Buffering Text Reflection");
	assert(text != nil);
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    [post_dict setObject:text forKey:@"text_reflection[text]"];
	[post_dict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"text_reflection[udid]"];
	//[post_dict setObject:[self getUserIdAsString] forKey:@"text_reflection[user_id]"];
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://wl58-rails.cac.cornell.edu/app/text_reflections"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
	NSLog(@"Contacting Rails....");
	[urlRequest retain];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:[[SyncManagerConnectionDelegate alloc] set:urlRequest withLock:[self urLock] withType:@"TextReflection"]];
}

-(void) sendPhotoReflection:(UIImage *)image{
	NSLog(@"Buffering Photo Reflection");
	assert(image != nil);
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
	[post_dict setObject:UIImageJPEGRepresentation(image, 0.75f) forKey:@"photo_reflection[uploaded_picture]"];
	[post_dict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"photo_reflection[udid]"];
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://wl58-rails.cac.cornell.edu/app/photo_reflections"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
	NSLog(@"Contacting Rails....");
	[urlRequest retain];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:[[SyncManagerConnectionDelegate alloc] set:urlRequest withLock:[self urLock] withType:@"PhotoReflection"]];
}

-(void) sendColorReflectionWithRed:(NSNumber*)r andGreen:(NSNumber*)g andBlue:(NSNumber*)b{
	NSLog(@"Buffering Color Reflection");
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    [post_dict setObject:[r stringValue] forKey:@"color_reflection[red]"];
	[post_dict setObject:[g stringValue] forKey:@"color_reflection[green]"];
	[post_dict setObject:[b stringValue] forKey:@"color_reflection[blue]"];
	[post_dict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"color_reflection[udid]"];
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://wl58-rails.cac.cornell.edu/app/color_reflections"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
	NSLog(@"Contacting Rails....");
	[urlRequest retain];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:[[SyncManagerConnectionDelegate alloc] set:urlRequest withLock:[self urLock] withType:@"ColorReflection"]];
}

-(void) sendDailySuggestion:(NSString*)theme andTime:(NSString *)timestamp{
	//assert([timestamp length] == 19); //Timestamps must be in yyyy-mm-dd hh:mm:ss format
	NSLog(@"Buffering Daily Suggestion");
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    [post_dict setObject:theme forKey:@"daily_suggestion[theme]"];
	[post_dict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"daily_suggestion[udid]"];
	[post_dict setObject:timestamp forKey:@"daily_suggestion[time_entered]"];
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://wl58-rails.cac.cornell.edu/app/daily_suggestions"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
	NSLog(@"Contacting Rails....");
	[urlRequest retain];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:[[SyncManagerConnectionDelegate alloc] set:urlRequest withLock:[self urLock] withType:@"DailySuggestion"]];
}

-(void) sendLogScreen:(int)screen_id andTime:(NSString *)timestamp{
	//assert([timestamp length] == 19); //Timestamps must be in yyyy-mm-dd hh:mm:ss format
	NSLog(@"Sending Log Screen");
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
    [post_dict setObject:[NSString stringWithFormat: @"%d", screen_id] forKey:@"log_screen[screen_id]"];
	[post_dict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"log_screen[udid]"];
	[post_dict setObject:timestamp forKey:@"log_screen[time_entered]"];
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://wl58-rails.cac.cornell.edu/app/log_screens"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
	NSLog(@"Contacting Rails....");
	[urlRequest retain];
	[[NSURLConnection alloc] initWithRequest:urlRequest delegate:[[SyncManagerConnectionDelegate alloc] set:urlRequest withLock:[self urLock] withType:@"LogScreen"]];
}

-(void)syncData{
//	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
//	[wifiReach startNotifier];
//	
//	NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
//	
//	// Pull any unsynchronized data from NSUserDefaults
//	NSMutableArray *ar = [[SyncManager getSyncManagerInstance] bufferedReflections];
//	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//	NSData *objectsData = [userDefaults objectForKey:@"savedArray"];
//	// if ([objectsData length] > 0) {
//	NSArray *objects = [NSKeyedUnarchiver unarchiveObjectWithData:objectsData];
//	// }
//	if(objects != nil && netStatus == ReachableViaWiFi){
//		[ar removeObjectsInArray:objects];
//		[ar addObjectsFromArray:objects];
//	}
//	NSLog(@"Loaded Buffered Data");
//	
//	// TODO Ensure that buffered stuff is preserved even when you exit the application
//	
//	// TODO Sync Suggestion of the Day
//	
//	NSMutableArray *objectsToDelete = [[NSMutableArray alloc] init];
//	
//	if(netStatus == ReachableViaWiFi){
//		NSLog(@"Wifi connection is turned on!!");
//		
//		// Sync any failed URLRequests
//		NSLog(@"Trying to sync any failed URLRequests...");
//		[[self urLock] lock];
//		NSMutableArray* aru = [[NSMutableArray alloc] init];
//		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//		NSData *objectsData = [userDefaults objectForKey:@"savedUrlRequests"];
//		NSArray *objects = [NSKeyedUnarchiver unarchiveObjectWithData:objectsData];
//		if(objects != nil){
//			[aru addObjectsFromArray:objects];
//		}
//		for(NSObject *o in aru){
//			NSMutableURLRequest* urq = (NSMutableURLRequest*) o;
//			[[NSURLConnection alloc] initWithRequest:urq delegate:[[SyncManagerConnectionDelegate alloc] set:urq withLock:[self urLock] withType:@"Retry"]];
//		}
//		[aru release];
//		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]] forKey:@"savedUrlRequests"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		[[self urLock] unlock];
//		NSLog(@"...finished initiating retries for failed URLRequests");
//		
//		// Sync other normal stuff
//		NSLog(@"Syncing Data");
//		for(NSObject* o in ar){
//			NSLog(@"Syncing object...");
//			NSLog([NSString stringWithFormat:@"Size of buffer array sending objects to server %i",[ar count]]);
//			if([o isKindOfClass:[NSString class]]){
//				NSString *s = (NSString*)o;
//				[self sendTextReflection:s];
//				[objectsToDelete addObject:o];
//			}
//			else if([o isKindOfClass:[ColorReflection class]]){
//				ColorReflection* cr = (ColorReflection*) o;
//				NSNumber* r = [cr colorRed];
//				NSNumber* g = [cr colorGreen];
//				NSNumber* b = [cr colorBlue];
//				NSLog(@"%f %f %f", [r floatValue], [g floatValue], [b floatValue]);
//				[self sendColorReflectionWithRed:r andGreen:g andBlue:b];
//				[objectsToDelete addObject:o];
//			}
//			else if([o isKindOfClass:[NSArray class]]){
//				// TODO Use this for daily suggestions instead
//				NSArray *d = (NSArray*)o;
//				NSString* suggestionTheme = (NSString*) [d objectAtIndex:0];
//				NSDate* time = [d objectAtIndex:1];
//				NSString* s = [time descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S %z" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
//				NSLog(@"%@", suggestionTheme);
//				[self sendDailySuggestion:suggestionTheme andTime:s];
//				[objectsToDelete addObject:o];
//			}
//			else if([o isKindOfClass:[UIImage class]]){
//				UIImage *i = (UIImage*)o;
//				[self sendPhotoReflection:i];
//				[objectsToDelete addObject:o];
//			}
//			else if([o isKindOfClass:[LogScreen class]]){
//				LogScreen* ls = (LogScreen*) o;
//				int screenId = [[ls screenId] intValue];
//				NSDate* time = [ls createdAt];
//				NSString* s = [time descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S %z" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
//				[self sendLogScreen:screenId andTime:s];
//				[objectsToDelete addObject:o];
//			}
//		}
//		[ar removeObjectsInArray:objectsToDelete];
//		[objectsToDelete release];
//		[[self urLock] lock];
//		[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:ar] forKey:@"savedArray"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		[[self urLock] unlock];
//		NSLog(@"Saved Buffered Data");
//	}
//	else {
//		NSLog(@"NO WIFI CONNECTION!!");
//	}
//	
//	NSLog(@"out of wifi if-then");
//	// Save to NSUserDefaults
//	[[self urLock] lock];
//	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:ar] forKey:@"savedArray"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	[[self urLock] unlock];
//	NSLog(@"Saved Buffered Data");
	
}

- (void) cleanup: (NSString *) output
{
	NSLog(@"Error occured - %@", output);
}

#pragma mark URLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Received response...");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *outstring = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"%@", [NSString stringWithFormat: @"Success: %@", outstring]);
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
	
    // inform the user, but now don't!
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error" message:[NSString stringWithFormat:@"The upload failed with this error: %@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alert show];
    //[alert release];
	
    NSLog(@"Connection failed! Error - %@",[error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Upload succeeded!");
    [connection release];
}
@end
