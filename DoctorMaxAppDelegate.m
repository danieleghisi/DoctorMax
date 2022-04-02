//
//  DoctorMaxAppDelegate.m
//  DoctorMax
//
//  Created by Daniele Ghisi on 09/09/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "DoctorMaxAppDelegate.h"
#include "DoctorMax.h"
#include "DMEntry.h"
#include <time.h>

@implementation DoctorMaxAppDelegate
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
#ifdef BACH_REF // bach initialization
    [source_folder1 setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/source/mains/"];
	[source_folder2 setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/source/abstractions/"];
    [source_folder3 setStringValue:@""];
    [source_folder4 setStringValue:@""];
    [recursive_folder1 setState:1];
    [recursive_folder2 setState:1];
	[commonref_file1 setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/source/commons/doc/bach_doc_commons.h"];
	[commonref_file2 setStringValue:@""];
    [commonref_file3 setStringValue:@""];
	[substitutions_file setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/source/commons/doc/bach_doc_substitutions.h"];
    [xml_output_folder setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/docs/refpages/bach_ref"];
	[txt_init_output_folder setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/init"];
	[json_interfaces_output_folder setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/interfaces"];
	[library_name setStringValue:@"bach"];
    [math_category setStringValue:@"bach math"];
    [help_source_folder setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/help"];
    [help_router setStringValue:@"bach.help"];
    [help_output_filename setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/help/bach.help.json"];
    [help_exclude setStringValue:@"bach.help.home.maxpat, bach.help.search.maxpat, bach.help.searchtag.maxpat"];
    [help_build setState:1];
    [help_recursive setState:0];
    [add_syntax_to_messages setState:1];
    [only_if_it_has_arguments setState:1];
    [patrons_build setState:1];
    [patrons_source_csv setStringValue:@"/Users/danieleghisi/Downloads/Members_2774862.csv"];
    [patrons_target_h setStringValue:@"/Users/danieleghisi/Documents/Max 8/Packages/bach/source/commons/patreon/patrons.h"];
    [patrons_addgpl3license setState:1];
    
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);

    [patrons_copyright setStringValue:[NSString stringWithFormat: @"Copyright (C) 2010-%d Andrea Agostini and Daniele Ghisi", tm.tm_year + 1900]];
    [patrons_mintopsupporterpledge setStringValue:@"8"];
#endif
	
	[currently_open_file setStringValue:@""];
	[progress_label setStringValue:@""];
    [overview_label setStringValue:@""];
	[progress_indicator setDisplayedWhenStopped:FALSE];
    
    list = [[NSMutableArray alloc] init];

/*    for (NSTableColumn *tableColumn in idTableView.tableColumns ) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES selector:@selector(compare:)];
        [tableColumn setSortDescriptorPrototype:sortDescriptor];
    }
  */  
}

- (NSTextField *) source_folder1 { return source_folder1; }
- (NSTextField *) source_folder2 { return source_folder2; }
- (NSTextField *) source_folder3 { return source_folder3; }
- (NSTextField *) source_folder4 { return source_folder4; }
- (NSButton *) recursive_folder1 { return recursive_folder1; }
- (NSButton *) recursive_folder2 { return recursive_folder2; }
- (NSButton *) recursive_folder3 { return recursive_folder3; }
- (NSButton *) recursive_folder4 { return recursive_folder4; }
- (NSTextField *) commonref_file1 { return commonref_file1; }
- (NSTextField *) commonref_file2 { return commonref_file2; }
- (NSTextField *) commonref_file3 { return commonref_file3; }
- (NSTextField *) substitutions_file { return substitutions_file; }
- (NSTextField *) xml_output_folder { return xml_output_folder; }
- (NSTextField *) txt_init_output_folder { return txt_init_output_folder; }
- (NSTextField *) json_interfaces_output_folder { return json_interfaces_output_folder; }
- (NSButton *) sort_attributes { return sort_attributes; }
- (NSButton *) sort_methods { return sort_methods; }
- (NSButton *) export_in_out_as_misc { return export_in_out_as_misc; }
- (NSButton *) export_discussion_as_misc { return export_discussion_as_misc; }
- (NSTextField *) currently_open_file { return currently_open_file; }

- (NSButton *) separate_tag_obj_and_abstr { return separate_tag_obj_and_abstr; }
- (NSButton *) produce_c74_contents_xml_file { return produce_c74_contents_xml_file; }
- (NSButton *) produce_interfaces_json_file { return produce_interfaces_json_file; }

- (NSButton *) build_objlist { return build_objlist; }
- (NSButton *) build_objmappings { return build_objmappings; }
- (NSButton *) build_database { return build_database; }
- (NSButton *) build_init_files { return build_init_files; }
- (NSTextField *) library_name { return library_name; }
- (NSTextField *) math_category { return math_category; }

- (NSButton *) help_build { return help_build; }
- (NSTextField *) help_source_folder { return help_source_folder; }
- (NSTextField *) help_router { return help_router; }
- (NSTextField *) help_output_filename { return help_output_filename; }
- (NSTextField *) help_exclude { return help_exclude; }
- (NSButton *) help_recursive { return help_recursive; }


- (NSButton *) patrons_build { return patrons_build; }
- (NSTextField *) patrons_source_csv { return patrons_source_csv; }
- (NSTextField *) patrons_target_h { return patrons_target_h; }
- (NSButton *) patrons_addgpl3license { return patrons_addgpl3license; }
- (NSTextField *) patrons_copyright { return patrons_copyright; }
- (NSTextField *) patrons_mintopsupporterpledge { return patrons_mintopsupporterpledge; }

void SetTextFromBrowsing(NSTextField* field, char folders)
{
	int i;
	// Create the File Open Dialog class.
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	
	// Enable the selection of files in the dialog.
	if (folders)
		[openDlg setCanChooseFiles:NO];
	else
		[openDlg setCanChooseFiles:YES];
	
	// Multiple files not allowed
	[openDlg setAllowsMultipleSelection:NO];
	
	// Can't select a directory
	if (folders)
		[openDlg setCanChooseDirectories:YES];
	else
		[openDlg setCanChooseDirectories:NO];
	
	// Display the dialog. If the OK button was pressed,
	// process the files.
	if ( [openDlg runModalForDirectory:nil file:nil] == NSOKButton )
	{
		// Get an array containing the full filenames of all
		// files and directories selected.
		NSArray* files = [openDlg filenames];
		
		// Loop through all the files and process them.
		if ([files count] > 0) {
			NSString* fileName = [files objectAtIndex:i];
			[field setStringValue:fileName];
		}
	}
}

- (IBAction)SetSourceFolder1:(id)sender
{
	SetTextFromBrowsing(source_folder1, 1);
}

- (IBAction)SetSourceFolder2:(id)sender
{
	SetTextFromBrowsing(source_folder2, 1);
}

- (IBAction)SetSourceFolder3:(id)sender
{
	SetTextFromBrowsing(source_folder3, 1);
}

- (IBAction)SetSourceFolder4:(id)sender
{
	SetTextFromBrowsing(source_folder4, 1);
}

- (IBAction)SetCommonRefFile1:(id)sender
{
	SetTextFromBrowsing(commonref_file1, 0);
}

- (IBAction)SetCommonRefFile2:(id)sender
{
	SetTextFromBrowsing(commonref_file2, 0);
}

- (IBAction)SetCommonRefFile3:(id)sender
{
    SetTextFromBrowsing(commonref_file3, 0);
}

- (IBAction)SetSubstitutionsFile:(id)sender
{
	SetTextFromBrowsing(substitutions_file, 0);
}

- (IBAction)SetOutputFolder:(id)sender
{
	SetTextFromBrowsing(xml_output_folder, 1);
}

- (IBAction)SetXmlOutputFolder:(id)sender
{
	SetTextFromBrowsing(xml_output_folder, 1);
}

- (IBAction)SetTxtInitOutputFolder:(id)sender
{
	SetTextFromBrowsing(txt_init_output_folder, 1);
}

- (IBAction)SetJsonInterfacesOutputFolder:(id)sender
{
	SetTextFromBrowsing(json_interfaces_output_folder, 1);
}


- (IBAction)SetHelpSourceFolder:(id)sender
{
    SetTextFromBrowsing(help_source_folder, 1);
}


- (IBAction)SetHelpRouter:(id)sender
{
    SetTextFromBrowsing(help_router, 1);
}

- (IBAction)SetHelpOutputFilename:(id)sender
{
    SetTextFromBrowsing(help_output_filename, 1);
}

- (IBAction)SetHelpExclude:(id)sender
{
    SetTextFromBrowsing(help_exclude, 1);
}



- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication 
{
    return YES;
}

/* qsort struct comparision function (price float field) */
int modules_cmp_alphabetically(const void *a, const void *b)
{
    t_doctor_max_module_stats *a_dm = (t_doctor_max_module_stats *)a;
    t_doctor_max_module_stats *b_dm = (t_doctor_max_module_stats *)b;
    return strcmp(a_dm->name, b_dm->name);
}

- (IBAction)CreateFiles:(id)sender
{
	long i;
    t_doctor_max_stats stats;
	[progress_indicator setUsesThreadedAnimation:YES];
	[progress_indicator startAnimation:self];
	[error_log setString:@""];
	
    
    for (i = 0; i < NUM_DOCTOR_MAX_MODULE_STATUS; i++)
        stats.num_abstractions[i] = stats.num_objects[i] = 0;
    stats.num_modules = 0;
    stats.module = malloc(MAX_MODULES * sizeof(t_doctor_max_module_stats));
    memset(stats.module, 0, MAX_MODULES * sizeof(t_doctor_max_module_stats));

    
	//	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
	//    dispatch_async(queue, ^{
	//		dispatch_sync(dispatch_get_main_queue(), ^{
    produceFiles([build_xml_files state] ? 1 : 0, [build_init_files state] ? 1 : 0,
					[[source_folder1 stringValue] UTF8String], [[source_folder2 stringValue] UTF8String], [[source_folder3 stringValue] UTF8String], [[source_folder4 stringValue] UTF8String],
					[recursive_folder1 state] ? 1 : 0, [recursive_folder2 state] ? 1 : 0, [recursive_folder3 state] ? 1 : 0, [recursive_folder4 state] ? 1 : 0, 
					[[commonref_file1 stringValue] UTF8String], [[commonref_file2 stringValue] UTF8String], [[commonref_file3 stringValue] UTF8String], [[substitutions_file stringValue] UTF8String],
					[[xml_output_folder stringValue] UTF8String], [[txt_init_output_folder stringValue] UTF8String], 
					progress_label, progress_indicator, error_log,
					[sort_attributes state] ? 1 : 0, [sort_methods state] ? 1 : 0, [export_in_out_as_misc state] ? 1 : 0, [export_discussion_as_misc state] ? 1 : 0,
					[[library_name stringValue] UTF8String], [build_database state], [build_objlist state], [build_objmappings state], 
					[separate_tag_obj_and_abstr state] ? 1 : 0, [produce_c74_contents_xml_file state] ? 1 : 0,
					[[json_interfaces_output_folder stringValue] UTF8String], [produce_interfaces_json_file state] ? 1 : 0,
                    [[math_category stringValue] UTF8String], overview_label, &stats, [add_syntax_to_messages state] ? ([only_if_it_has_arguments state] ? 1 : 2) : 0,
                 
#ifdef BACH_REF		
				 true);
#else
				 false);
#endif
	

    
    /// PRODUCE HELP FILES????
    if ([help_build state]) {
        t_doctor_max_help_stats help_stats;
        char str[100000];
        char *exclude[MAX_HELP_EXCLUDE];
        long i, num_exclude = 0;
        for (i = 0; i < MAX_HELP_EXCLUDE; i++)
            exclude[i] = malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
        
        strncpy(str, [[help_exclude stringValue] UTF8String], 100000-1);
        split_string(str, ",", exclude, MAX_HELP_EXCLUDE, &num_exclude);
        
//        const char *exclude[] = {"bach.help.home.maxpat", "bach.help.search.maxpat", "bach.help.searchtag.maxpat"};
//        const long num_exclude = 3;
        
        
        produceHelpFiles([[help_source_folder stringValue] UTF8String], [help_recursive state] ? 1 : 0, [[help_router stringValue] UTF8String], [[help_output_filename stringValue] UTF8String], progress_label, error_log, &help_stats, num_exclude, exclude);
        
        for (i = 0; i < MAX_HELP_EXCLUDE; i++)
            free(exclude[i]);
    }
    
    // PRODUCE PATRONS CODE?
    if ([patrons_build state]) {
        producePatronsCode([[patrons_source_csv stringValue] UTF8String], [[patrons_target_h stringValue] UTF8String], error_log, [patrons_addgpl3license state], [[patrons_copyright stringValue] UTF8String], atol([[patrons_mintopsupporterpledge stringValue] UTF8String]));
    }
    
    
    // FILLING RESULT OVERVIEW
    {
        // Sorting overview by name
//        qsort(stats.module, stats.num_modules, sizeof(t_doctor_max_module_stats), modules_cmp_alphabetically);
        
        
        NSFont *standardFont = [NSFont systemFontOfSize:11];
        NSFont *boldFont = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:11] toHaveTrait:NSFontBoldTrait];
        NSFont *italicFont = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:11] toHaveTrait:NSFontItalicTrait];
        
        NSDictionary *standard = [NSDictionary dictionaryWithObject:standardFont forKey:NSFontAttributeName];
        NSDictionary *bold = [NSDictionary dictionaryWithObject:boldFont forKey:NSFontAttributeName];
        NSDictionary *hidden = [NSDictionary dictionaryWithObject:italicFont forKey:NSFontAttributeName];
        NSDictionary *experimental = [NSDictionary dictionaryWithObject:italicFont forKey:NSFontAttributeName];
        NSDictionary *strikethrough = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
        NSMutableDictionary *deprecated = [hidden mutableCopy];
        [deprecated addEntriesFromDictionary:strikethrough];

        
        [list removeAllObjects];
        
        for (i = 0; i < stats.num_modules; i++) {
            NSDictionary *this_dict = (stats.module[i].status == k_STATUS_DEPRECATED ? deprecated :
                                       (stats.module[i].status == k_STATUS_HIDDEN ? hidden :
                                        (stats.module[i].status == k_STATUS_EXPERIMENTAL ? experimental : standard)));
            
            NSMutableDictionary *this_dict_and_bold = [this_dict mutableCopy];
            [this_dict_and_bold addEntriesFromDictionary:bold];
            
            NSAttributedString *names_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%s", stats.module[i].name] attributes:this_dict];
            NSAttributedString *realNames_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%s", stats.module[i].real_name]
                                                                              attributes:(strcmp(stats.module[i].name, stats.module[i].real_name) == 0 ? this_dict : this_dict_and_bold)];
            NSAttributedString *digest_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%s", stats.module[i].digest] attributes:this_dict];
            NSAttributedString *cSource_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%s", stats.module[i].c_source] attributes:this_dict];
            NSAttributedString *owners_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%s", stats.module[i].owner] attributes:this_dict];
            NSAttributedString *types_S, *status_S;
            NSMutableAttributedString *categories_S = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @""] attributes:this_dict];
            NSMutableAttributedString *seealso_S = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @""] attributes:this_dict];
            NSMutableAttributedString *keywords_S = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @""] attributes:this_dict];
            
            long j;
            for (j = 0; j < stats.module[i].num_categories; j++) {
                NSAttributedString *this_cat = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: (j == stats.module[i].num_categories - 1 ? @"%s" : @"%s, "), stats.module[i].category[j]] attributes:this_dict];
                [categories_S appendAttributedString:this_cat];
            }
            for (j = 0; j < stats.module[i].num_seealso; j++) {
                NSAttributedString *this_cat = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: (j == stats.module[i].num_seealso - 1 ? @"%s" : @"%s, "), stats.module[i].seealso[j]] attributes:this_dict];
                [seealso_S appendAttributedString:this_cat];
            }
            for (j = 0; j < stats.module[i].num_keywords; j++) {
                NSAttributedString *this_cat = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: (j == stats.module[i].num_keywords - 1 ? @"%s" : @"%s, "), stats.module[i].keyword[j]] attributes:this_dict];
                [keywords_S appendAttributedString:this_cat];
            }
  
            switch (stats.module[i].type) {
                case k_TYPE_OBJECT:
                    types_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"object"] attributes:this_dict];
                    break;
                case k_TYPE_ABSTRACTION:
                    types_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"abstraction"] attributes:this_dict];
                    break;
                default:
                    types_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"unknown"] attributes:this_dict];
                    break;
            }
            switch (stats.module[i].status) {
                case k_STATUS_EXPERIMENTAL:
                    status_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"experimental"] attributes:this_dict];
                    break;
                case k_STATUS_DEPRECATED:
                    status_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"deprecated"] attributes:this_dict];
                    break;
                case k_STATUS_HIDDEN:
                    status_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"hidden"] attributes:this_dict];
                    break;
                default:
                    status_S = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"regular"] attributes:this_dict];
                    break;
            }
            
            DMEntry *E = [[DMEntry alloc] init];
            [E setValue:names_S forKey:@"name"];
            [E setValue:realNames_S forKey:@"realname"];
            [E setValue:digest_S forKey:@"digest"];
            [E setValue:seealso_S forKey:@"seealso"];
            [E setValue:status_S forKey:@"status"];
            [E setValue:types_S forKey:@"type"];
            [E setValue:categories_S forKey:@"categories"];
            [E setValue:keywords_S forKey:@"keywords"];
            [E setValue:cSource_S forKey:@"csource"];
            [E setValue:owners_S forKey:@"owner"];
            [list addObject:E];
//            [E release];

            
        }
        
        [idTableView reloadData];
        
    }
    
    
    //    free(stats->module);

    
	//		});
	//    });
	
	[progress_indicator stopAnimation:self];
	[progress_label setStringValue:@"Done!"];
	for (i = 0; i < 10; i++) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.1]];
	}
	[progress_label setStringValue:@""];
}



- (BOOL)application:(NSApplication *)theApplication saveFile:(NSString *)filename
{
	NSString *str = [NSString stringWithFormat: @"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%d\n%@\n%d\n%d\n%d\n%d\n%d\n%@\n%@\n%d\n%@\n%d\n%@\n%d\n%@\n%@\n%@\n%@\n",
					 [source_folder1 stringValue], [source_folder2 stringValue], 
					 [source_folder3 stringValue], [source_folder4 stringValue], 
					 [commonref_file1 stringValue], [commonref_file2 stringValue], 
					 [xml_output_folder stringValue], [txt_init_output_folder stringValue],
					 [build_xml_files state] ? 1 : 0, [sort_attributes state] ? 1 : 0, 
					 [sort_methods state] ? 1 : 0, [export_in_out_as_misc state] ? 1 : 0, 
					 [export_discussion_as_misc state] ? 1 : 0,
					 [build_init_files state] ? 1 : 0, [build_database state] ? 1 : 0,
					 [build_objlist state] ? 1 : 0, [separate_tag_obj_and_abstr state] ? 1 : 0,
					 [build_objmappings state] ? 1 : 0, [library_name stringValue],
					 [produce_c74_contents_xml_file state] ? 1 : 0, 
					 [recursive_folder1 state] ? 1 : 0, [recursive_folder2 state] ? 1 : 0, 
					 [recursive_folder3 state] ? 1 : 0, [recursive_folder4 state] ? 1 : 0,
  					 [substitutions_file stringValue], [json_interfaces_output_folder stringValue], [produce_interfaces_json_file state] ? 1 : 0, [math_category stringValue],
                     [help_build state] ? 1 : 0,
                     [help_source_folder stringValue],
                     [help_recursive state] ? 1 : 0,
                     [help_router stringValue],
                     [help_output_filename stringValue],
                     [help_exclude stringValue],
                     [commonref_file3 stringValue],
                     [add_syntax_to_messages state],
                     [only_if_it_has_arguments state],
                     [patrons_build state] ? 1 : 0,
                     [patrons_source_csv stringValue],
                     [patrons_target_h stringValue],
                     [patrons_addgpl3license state] ? 1 : 0,
                     [patrons_copyright stringValue],
                     [patrons_mintopsupporterpledge stringValue]
                     ];
	
	[str writeToFile:filename atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
	[currently_open_file setStringValue:filename];
	return YES;
}


- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSString *fh = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
	long i = 0;

    [patrons_build setState:0];
    [patrons_source_csv setStringValue:@""];
    [patrons_target_h setStringValue:@""];
    [patrons_addgpl3license setState:0];
    [patrons_copyright setStringValue:@""];
    [patrons_mintopsupporterpledge setStringValue:@""];
    
	for (NSString *line in [fh componentsSeparatedByString:@"\n"]) {
		i++;
		switch (i) {
			case 1: [source_folder1 setStringValue:line]; break;
			case 2: [source_folder2 setStringValue:line]; break;
			case 3: [source_folder3 setStringValue:line]; break;
			case 4: [source_folder4 setStringValue:line]; break;
			case 5: [commonref_file1 setStringValue:line]; break;
			case 6: [commonref_file2 setStringValue:line]; break;
			case 7: [xml_output_folder setStringValue:line]; break;
			case 8: [txt_init_output_folder setStringValue:line]; break;
			case 9: [build_xml_files setState:[line intValue]]; break;
			case 10: [sort_attributes setState:[line intValue]]; break;
			case 11: [sort_methods setState:[line intValue]]; break;
			case 12: [export_in_out_as_misc setState:[line intValue]]; break;
			case 13: [export_discussion_as_misc setState:[line intValue]]; break;
			case 14: [build_init_files setState:[line intValue]]; break;
			case 15: [build_database setState:[line intValue]]; break;
			case 16: [build_objlist setState:[line intValue]]; break;
			case 17: [separate_tag_obj_and_abstr setState:[line intValue]]; break;
			case 18: [build_objmappings setState:[line intValue]]; break;
			case 19: [library_name setStringValue:line]; break;
			case 20: [produce_c74_contents_xml_file setState:[line intValue]]; break;
			case 21: [recursive_folder1 setState:[line intValue]]; break;
			case 22: [recursive_folder2 setState:[line intValue]]; break;
			case 23: [recursive_folder3 setState:[line intValue]]; break;
			case 24: [recursive_folder4 setState:[line intValue]]; break;
			case 25: [substitutions_file setStringValue:line]; break;
			case 26: [json_interfaces_output_folder setStringValue:line]; break;
			case 27: [produce_interfaces_json_file setState:[line intValue]]; break;
            case 28: [math_category setStringValue:line]; break;
            // help center
            case 29: [help_build setState:[line intValue]]; break;
            case 30: [help_source_folder setStringValue:line]; break;
            case 31: [help_recursive setState:[line intValue]]; break;
            case 32: [help_router setStringValue:line]; break;
            case 33: [help_output_filename setStringValue:line]; break;
            case 34: [help_exclude setStringValue:line]; break;
            case 35: [commonref_file3 setStringValue:line]; break;
            case 36: [add_syntax_to_messages setState:[line intValue]]; break;
            case 37: [only_if_it_has_arguments setState:[line intValue]]; break;
            case 38: [patrons_build setState:[line intValue]]; break;
            case 39: [patrons_source_csv setStringValue:line]; break;
            case 40: [patrons_target_h setStringValue:line]; break;
            case 41: [patrons_addgpl3license setState:[line intValue]]; break;
            case 42: [patrons_copyright setStringValue:line]; break;
            case 43: [patrons_mintopsupporterpledge setStringValue:line]; break;
		}
	}
	[currently_open_file setStringValue:filename];
	[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
	return YES;
}



//// TABLE STUFF

/*- (NSMutableArray *)tabledata {
    
    if (!tabledata) {
        tabledata = [[NSMutableArray alloc] init];
    }
    return tabledata;
} */

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    // how many rows do we have here?
    return [list count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // populate each row of our table view with data
    // display a different value depending on each column (as identified in XIB)
    
    
    NSString *identifier = [tableColumn identifier];  // get the column identifier
    DMEntry *entry = [list objectAtIndex:row];
    return [entry valueForKey:identifier];
}


#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}



-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange: (NSArray *)oldDescriptors
{
    NSArray *newDescriptors = [tableView sortDescriptors];
    [list sortUsingDescriptors:newDescriptors];
    //"results" is my NSMutableArray which is set to be the data source for the NSTableView object.
    [tableView reloadData];
}


@end
