//
//  DMEntry.m
//  DoctorMax
//
//  Created by Daniele Ghisi on 15/01/16.
//
//

#import "DMEntry.h"

@implementation DMEntry

@synthesize name;
@synthesize realname;
@synthesize csource;
@synthesize type;
@synthesize digest;
@synthesize owner;
@synthesize status;
@synthesize categories;
@synthesize seealso;
@synthesize keywords;

- (id)init
{
    self = [super init];
    if (self){
        name = @"Yoda";
        realname = @"Yoda";
        csource = @"Yoda";
        type = @"Yoda";
        digest = @"Yoda";
        owner = @"Yoda";
        status = @"Yoda";
        categories = @"Yoda";
        seealso = @"Yoda";
        keywords = @"YodaK";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
