//
//  LogScreen.m
//  goslowtest2
//
//  Created by Kevin Tse on 11/2/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "LogScreen.h"
#import "goslowtest2AppDelegate.h"

NSString *kURIRepresentationKey = @"LogScreenRepresentation";

@implementation LogScreen

@dynamic screenId;
@dynamic createdAt;

- (id)initWithCoder:(NSCoder *)decoder {
    goslowtest2AppDelegate *appDelegate = (goslowtest2AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *psc = [appDelegate persistentStoreCoordinator];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    self = (LogScreen *)[[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:kURIRepresentationKey]]] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[[self objectID] URIRepresentation] forKey:kURIRepresentationKey];
}

@end
