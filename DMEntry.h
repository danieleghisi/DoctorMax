//
//  DMEntry.h
//  DoctorMax
//
//  Created by Daniele Ghisi on 15/01/16.
//
//

#import <Foundation/Foundation.h>

@interface DMEntry : NSObject {
@private
    NSString *name;
    NSString *realname;
    NSString *digest;
    NSString *type;
    NSString *status;
    NSString *categories;
    NSString *owner;
    NSString *csource;
    NSString *seealso;
    NSString *keywords;
}

@property (copy) NSString *name;
@property (copy) NSString *realname;
@property (copy) NSString *digest;
@property (copy) NSString *type;
@property (copy) NSString *status;
@property (copy) NSString *categories;
@property (copy) NSString *owner;
@property (copy) NSString *csource;
@property (copy) NSString *seealso;
@property (copy) NSString *keywords;

@end
