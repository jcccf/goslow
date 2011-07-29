//
//  ColorReflection.h
//  goslowtest2
//
//  Created by Kevin Tse on 10/27/10.
//  Copyright 2010 Cornell University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reflection.h"

@interface ColorReflection : Reflection <NSCoding> {
}

@property (nonatomic, retain) NSNumber *colorRed;
@property (nonatomic, retain) NSNumber *colorGreen;
@property (nonatomic, retain) NSNumber *colorBlue;
@end
