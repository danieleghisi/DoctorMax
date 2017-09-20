//
//  MySaveMenuController.m
//  MaxReferenceGenerator
//
//  Created by Daniele Ghisi on 10/09/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MySaveMenuController.h"
#import "DoctorMaxAppDelegate.h"

@implementation MySaveMenuController


- (IBAction)doSaveAs:(id)pId; {	
	NSLog(@"doSaveAs");	
	NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
	int tvarInt	= [tvarNSSavePanelObj runModal];
	if (tvarInt == NSOKButton){
     	NSLog(@"doSaveAs we have an OK button");	
	} else if(tvarInt == NSCancelButton) {
     	NSLog(@"doSaveAs we have a Cancel button");
     	return;
	} else {
     	NSLog(@"doSaveAs tvarInt not equal 1 or zero = %3d",tvarInt);
     	return;
	} // end if     
	
	NSString * tvarDirectory = [tvarNSSavePanelObj directory];
	NSLog(@"doSaveAs directory = %@",tvarDirectory);
	
	NSString * tvarFilename = [tvarNSSavePanelObj filename];
	NSLog(@"doSaveAs filename = %@",tvarFilename);
	
	// real save part
	DoctorMaxAppDelegate *appDelegate = (DoctorMaxAppDelegate *)[NSApplication sharedApplication].delegate;
	[appDelegate application:[NSApplication sharedApplication] saveFile:tvarFilename];

} // end doSaveAs


- (IBAction)doSave:(id)pId; {	
	DoctorMaxAppDelegate *appDelegate = (DoctorMaxAppDelegate *)[NSApplication sharedApplication].delegate;
	NSString *str = [appDelegate.currently_open_file stringValue];
	if ([str length] > 0) {
		[appDelegate application:[NSApplication sharedApplication] saveFile:str];
	} else {
		[self doSaveAs:self];
	}
}


- (IBAction)doOpen:(id)pId; {	
	NSLog(@"doOpen");	
	NSOpenPanel *tvarNSOpenPanelObj	= [NSOpenPanel openPanel];
	NSInteger tvarNSInteger	= [tvarNSOpenPanelObj runModalForTypes:nil];
	if(tvarNSInteger == NSOKButton){
     	NSLog(@"doOpen we have an OK button");	
	} else if(tvarNSInteger == NSCancelButton) {
     	NSLog(@"doOpen we have a Cancel button");
		return;
	} else {
		NSLog(@"doOpen tvarInt not equal 1 or zero = %3d",tvarNSInteger);
		return;
	} // end if     
	
	NSString * tvarDirectory = [tvarNSOpenPanelObj directory];
	NSLog(@"doOpen directory = %@",tvarDirectory);
	
	NSString * tvarFilename = [tvarNSOpenPanelObj filename];
	NSLog(@"doOpen filename = %@",tvarFilename);
	
	// real open part
	DoctorMaxAppDelegate *appDelegate = (DoctorMaxAppDelegate *)[NSApplication sharedApplication].delegate;
	[appDelegate application:[NSApplication sharedApplication] openFile:tvarFilename];
} // end doOpen

@end