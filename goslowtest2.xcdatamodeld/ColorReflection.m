//
//  ColorReflection.m
//  goslowtest2
//
//  Created by Kevin Tse on 10/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import "ColorReflection.h"
#import "goslowtest2AppDelegate.h"

NSString *kColorRefRepresentationKey = @"ColorReflectionRepresentation";

@implementation ColorReflection

@dynamic colorRed;
@dynamic colorGreen;
@dynamic colorBlue;

- (id)initWithCoder:(NSCoder *)decoder {
    goslowtest2AppDelegate *appDelegate = (goslowtest2AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSPersistentStoreCoordinator *psc = [appDelegate persistentStoreCoordinator];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    self = (ColorReflection *)[[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:kColorRefRepresentationKey]]] retain];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[[self objectID] URIRepresentation] forKey:kColorRefRepresentationKey];
}

@end