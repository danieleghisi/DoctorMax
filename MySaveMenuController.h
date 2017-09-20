//
//  MySaveMenuController.h
//  MaxReferenceGenerator
//
//  Created by Daniele Ghisi on 10/09/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface  MySaveMenuController : NSMenu {
}
- (IBAction)doSaveAs:(id)pId;
- (IBAction)doOpen:(id)pId;
- (IBAction)doSave:(id)pId;

@end