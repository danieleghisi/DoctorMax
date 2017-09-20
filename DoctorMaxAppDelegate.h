//
//  DoctorMaxGeneratorAppDelegate.h
//  DoctorMaxGenerator
//
//  Created by Daniele Ghisi on 09/09/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Folders containing source files. You can define up to 4 source folders.
// Folders you don't need must be left as ""
#define SOURCES_FOLDER_1 "/Developer/SDKs/MaxSDK-6.1.3/bach/mains/aa"
#define SOURCES_FOLDER_2 "/Developer/SDKs/MaxSDK-6.1.3/bach/abstractions/aa"
#define SOURCES_FOLDER_3 "/Developer/SDKs/MaxSDK-6.1.3/bach/mains/dg"
#define SOURCES_FOLDER_4 "/Developer/SDKs/MaxSDK-6.1.3/bach/abstractions/dg"

// Folders containing definitions of common reference portions.
// You can define up to 2 common source folders.
// Folders you don't need must be left as ""
#define SOURCE_COMMON_REFERENCE_1 "/Developer/SDKs/MaxSDK-6.1.3/bach/commons/dg/bach_doc_commons_dg.h"
#define SOURCE_COMMON_REFERENCE_2 "/Developer/SDKs/MaxSDK-6.1.3/bach/commons/aa/bach_doc_commons_aa.h"
#define DESTINATION_XML_PATH "/Applications/Max 6.1/packages/bach/docs/refpages/bach_ref"

@interface DoctorMaxAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource> {
    NSWindow *window;
	IBOutlet NSTextField *source_folder1;
	IBOutlet NSTextField *source_folder2;
	IBOutlet NSTextField *source_folder3;
	IBOutlet NSTextField *source_folder4;
	
	IBOutlet NSButton *recursive_folder1;
	IBOutlet NSButton *recursive_folder2;
	IBOutlet NSButton *recursive_folder3;
	IBOutlet NSButton *recursive_folder4;

	IBOutlet NSTextField *commonref_file1;
	IBOutlet NSTextField *commonref_file2;
    IBOutlet NSTextField *commonref_file3;
	IBOutlet NSTextField *xml_output_folder;
	IBOutlet NSTextField *txt_init_output_folder;
	IBOutlet NSTextField *json_interfaces_output_folder;
	IBOutlet NSTextField *substitutions_file;
	
	IBOutlet NSTextField *progress_label;
	IBOutlet NSProgressIndicator *progress_indicator;
	
	IBOutlet NSButton *build_xml_files;
	IBOutlet NSButton *sort_attributes;
	IBOutlet NSButton *sort_methods;
	IBOutlet NSButton *export_in_out_as_misc;
	IBOutlet NSButton *export_discussion_as_misc;

	IBOutlet NSButton *build_init_files;
	IBOutlet NSButton *build_database;
	IBOutlet NSButton *build_objlist;
	IBOutlet NSButton *build_objmappings;
	IBOutlet NSButton *separate_tag_obj_and_abstr;
 	IBOutlet NSTextField *library_name;
    IBOutlet NSTextField *math_category;
    
	IBOutlet NSButton *produce_c74_contents_xml_file;
	IBOutlet NSButton *produce_interfaces_json_file;

	IBOutlet NSTextView *error_log;
	
    IBOutlet NSTextField *overview_label;
    
	IBOutlet NSTextField *currently_open_file;
    
    // Help center
    IBOutlet NSButton *help_build;
    IBOutlet NSTextField *help_source_folder;
    IBOutlet NSTextField *help_router;
    IBOutlet NSButton *help_recursive;
    IBOutlet NSTextField *help_output_filename;
    IBOutlet NSTextField *help_exclude;
    
    IBOutlet NSButton *add_syntax_to_messages;
    IBOutlet NSButton *only_if_it_has_arguments;

    
    // overview list
    NSMutableArray *list;
    IBOutlet NSTableView *idTableView;
    IBOutlet NSArrayController *arrayController;
}

@property (nonatomic, strong) NSMutableArray *list;
@property (assign) IBOutlet NSArrayController *arrayController;
@property (assign) IBOutlet NSTableView *idTableView;

- (BOOL)application:(NSApplication *)theApplication saveFile:(NSString *)filename;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

- (IBAction)SetSourceFolder1:(id)sender;
- (IBAction)SetSourceFolder2:(id)sender;
- (IBAction)SetSourceFolder3:(id)sender;
- (IBAction)SetSourceFolder4:(id)sender;
- (IBAction)SetCommonRefFile1:(id)sender;
- (IBAction)SetCommonRefFile2:(id)sender;
- (IBAction)SetSubstitutionsFile:(id)sender;
- (IBAction)SetXmlOutputFolder:(id)sender;
- (IBAction)SetTxtInitOutputFolder:(id)sender;
- (IBAction)SetJsonInterfacesOutputFolder:(id)sender;
- (IBAction)CreateFiles:(id)sender;

- (NSTextField *) source_folder1;
- (NSTextField *) source_folder2;
- (NSTextField *) source_folder3;
- (NSTextField *) source_folder4;

- (NSButton *) recursive_folder1;
- (NSButton *) recursive_folder2;
- (NSButton *) recursive_folder3;
- (NSButton *) recursive_folder4;

- (NSTextField *) commonref_file1;
- (NSTextField *) commonref_file2;
- (NSTextField *) commonref_file3;
- (NSTextField *) substitutions_file;
- (NSTextField *) xml_output_folder;
- (NSTextField *) txt_init_output_folder;
- (NSTextField *) json_interfaces_output_folder;

- (NSButton *) sort_attributes;
- (NSButton *) sort_methods;
- (NSButton *) export_in_out_as_misc;
- (NSButton *) export_discussion_as_misc;
- (NSTextField *) currently_open_file;

- (NSButton *) build_init_files;
- (NSButton *) build_database;
- (NSButton *) build_objlist;
- (NSButton *) build_objmappings;
- (NSButton *) separate_tag_obj_and_abstr;
- (NSTextField *) library_name;
- (NSTextField *) math_category;

- (NSButton *) produce_c74_contents_xml_file;
- (NSButton *) produce_interfaces_json_file;


- (NSButton *) help_build;
- (NSTextField *) help_source_folder;
- (NSTextField *) help_router;
- (NSButton *) help_recursive;
- (NSTextField *) help_output_filename;
- (NSTextField *) help_exclude;

//- (UITableViewCell *)tableView:(UITableView *)tableView
//       cellForRowAtIndexPath:(NSIndexPath *)indexPath

@property (assign) IBOutlet NSWindow *window;

@end
