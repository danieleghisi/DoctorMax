//
//  main.m
//  Doctor Max
//
//  Created by Daniele Ghisi on 09/09/13.
//  Copyright 2013 Daniele Ghisi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "stdio.h"
#include "dirent.h"
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <sys/stat.h>
#include "DoctorMax.h"



void harvest_aliases(char *path, char recursive, NSTextView *error_log);
void add_alias(char *alias, char *realname);
                       
void process_directory(char export_XMLs, char *path, char recursive,
					   char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, char *output_folder,
					   char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
					   NSTextField *progress_label, NSTextView *error_log, 
					   FILE *fp_database, FILE *fp_objectlist, FILE *fp_objectmappings, FILE *fp_object_qlookup, char separate_obj_and_abstr_in_objectlist,
					   char *library_name, FILE *fp_c74contents, char *substitutions_file, char **substitutions_tags, 
					   long num_substitutions_tags, t_doctor_max_stats *stats, char *math_category, char add_syntax_before_method_description, char for_bach);

void process_file(char export_XMLs, char *path, char *filename, 
				  char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, char *output_folder,
				  char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
				  NSTextField *progress_label, NSTextView *error_log, 
				  FILE *fp_database, FILE *fp_objectlist, FILE *fp_objectmappings, FILE *fp_object_qlookup, char separate_obj_and_abstr_in_objectlist,
				  char *library_name, FILE *fp_c74contents, char *substitutions_file, char **substitutions_tags, 
				  long num_substitutions_tags, t_doctor_max_stats *stats, char *math_category, char add_syntax_before_method_description, char for_bach);

void replace_standard(char *buf, long num_chars);
char *lefttrim(char *str, char also_trim_slashes);
void righttrim(char *str, char stop_at_first_space);
void righttrim_with_at(char *str);
char obtain_common_reference(char *ref_tag, char **lines_to_add, long *num_lines_to_add, char *reference_path,
							 char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, NSTextView *error_log, char no_spaces_tag, char only_copy_slashed_lines);
void replace_char(char *string, long allocated_size, char char_to_replace, char *replacement_string);
void replace_substring(char *string, long allocated_size, char *substring_to_replace, char *replacement_string);
char *get_next_double_quotes(char *string, char exclude_backslashed);
void substitute_slashed_quotes_in_string_with_escaped_quotes(char *string, long max_string_length);

long recursion_depth = 0;


int main(int argc, char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}


typedef struct _indexed_name
{
	char name[MAX_SINGLE_ELEM_CHARS];
	long idx;
} t_indexed_name;



int indexed_name_cmp(const void *a, const void *b)
{
	return strcmp(((t_indexed_name *)a)->name, ((t_indexed_name *)b)->name);
}


char contains_metadata(char *path, char *filename, NSTextView *error_log)
{
	FILE *fp_read;
	char fullfilename_read[300];
	long len_path_read = strlen(path);
	char line[MAX_LINE_CHARS];
	char res = false;
	
	strcpy(fullfilename_read, path);
	fullfilename_read[len_path_read] = '/';
	strcpy(fullfilename_read + len_path_read + 1, filename);
	
	fp_read = fopen(fullfilename_read, "r");
	
	if (fp_read == NULL) {
		[error_log setString:[NSString stringWithFormat: @"%@ • Failed to open file %s for read.\n", [error_log string], fullfilename_read]];
		return 0;
    }
	
	while (fgets(line, sizeof line, fp_read) != NULL)
	{
		char *trimmed = lefttrim(line, false);
		if (trimmed && strlen(trimmed) >= 7 && strncmp(trimmed, "@digest", 7) == 0){
			res = true;
			break;
		}
	}
	
	fclose(fp_read);
	return res;
}


void produceFiles(char export_XMLs, char export_TXTs,
					 const char *sources_folder1, const char *sources_folder2, const char *sources_folder3, const char *sources_folder4,
					 char folder1_recursive, char folder2_recursive, char folder3_recursive, char folder4_recursive,
					 const char *common_ref_file1, const char *common_ref_file2, const char *common_ref_file3, const char *substitutions_file, const char *XML_output_folder, const char *init_TXT_output_folder,
					 NSTextField *progress_label, NSProgressIndicator *progress_indicator, NSTextView *error_log,
					 char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
					 const char *library_name, char write_database_init, char write_objectlist_init, char write_objectmappings_init,
					 char separate_objs_and_abstrs_in_objlist, char write_c74contents, const char *interfaces_JSON_output_folder, char write_object_qlookup, const char *math_category, NSTextField *overview_label, t_doctor_max_stats *stats,
					char add_syntax_before_method_description, char for_bach)
{
	//	For single file debug:
	//	process_file(SOURCES_PATH_DG_ABSTRACTIONS, "istruct.c");
	//	return 0;
	
	FILE *fp_database = NULL, *fp_objectlist = NULL, *fp_objectmappings = NULL, *fp_c74contents = NULL, *fp_object_qlookup = NULL;
	char temp[300];

	
	if (export_TXTs && write_database_init) {
		snprintf(temp, 299, "%s/%s-database.txt", init_TXT_output_folder, library_name);
		[error_log setString:[NSString stringWithFormat: @"%@ A database file will be written.\n", [error_log string]]];
		fp_database = fopen(temp, "w");
		
		if (fp_database == NULL)
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open database file for write.\n", [error_log string]]];
	}
	
	if (export_TXTs && write_objectlist_init) {
		snprintf(temp, 299, "%s/%s-objectlist.txt", init_TXT_output_folder, library_name);
		[error_log setString:[NSString stringWithFormat: @"%@ An objectlist file will be written.\n", [error_log string]]];
		fp_objectlist = fopen(temp, "w");
		
		if (fp_objectlist == NULL)
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open objectlist file for write.\n", [error_log string]]];
	}
	
	if (export_TXTs && write_objectmappings_init) {
		snprintf(temp, 299, "%s/%s-objectmappings.txt", init_TXT_output_folder, library_name);
		[error_log setString:[NSString stringWithFormat: @"%@ An objectmappings file will be written.\n", [error_log string]]];
		fp_objectmappings = fopen(temp, "w");
		
		if (fp_objectmappings == NULL)
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open objectmappings file for write.\n", [error_log string]]];
	}
	
	if (write_c74contents) {
		snprintf(temp, 299, "%s/_c74_contents.xml", XML_output_folder);
		[error_log setString:[NSString stringWithFormat: @"%@ The _c74_contents.xml file will be written.\n", [error_log string]]];
		fp_c74contents = fopen(temp, "w");
		
		if (fp_c74contents == NULL)
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open _c74_contents.xml for write.\n", [error_log string]]];
		else {
			fprintf(fp_c74contents,"<?xml version='1.0' encoding='UTF-8' standalone='yes'?>\n");
			fprintf(fp_c74contents,"<root>\n");
		}
	}
	
	if (write_object_qlookup) {
		snprintf(temp, 299, "%s/%s-obj-qlookup.json", interfaces_JSON_output_folder, library_name);
		[error_log setString:[NSString stringWithFormat: @"%@ An interfaces obj-qlookup file will be written.\n", [error_log string]]];
		fp_object_qlookup = fopen(temp, "w");
		
		if (fp_object_qlookup == NULL)
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open interfaces obj-qlookup for write.\n", [error_log string]]];
		else {
			fprintf(fp_object_qlookup,"{\n");
		}
	}
	
	
	// PARSING SUBSTITUTIONS FILE, to retrieve substitution tags, if any
	long num_substitutions_tags = 0;
	char *substitutions_tags[MAX_SUBSTITUTIONS];
	long i;
	char line[MAX_LINE_CHARS];
	for (i = 0; i < MAX_SUBSTITUTIONS; i++)
		substitutions_tags[i] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	
	if (substitutions_file) {
		FILE *fpsub_read = fopen(substitutions_file, "r");
		
		if (fpsub_read == NULL) {
			[error_log setString:[NSString stringWithFormat: @"%@ Failed to open file %s for read.\n", [error_log string], substitutions_file]];

		} else {
		
			while (true) /* read a line */
			{
				if (fgets(line, sizeof line, fpsub_read) == NULL)
					break;
				
				if (num_substitutions_tags >= MAX_SUBSTITUTIONS)
					break;
				
				char *trimmed = lefttrim(line, false);
				if (trimmed) {
					if (strncmp(trimmed, "#define ", 8) == 0) {
						trimmed = lefttrim(trimmed + 8, false);
						strncpy(substitutions_tags[num_substitutions_tags], trimmed, MAX_SINGLE_ELEM_CHARS - 1);
						righttrim(substitutions_tags[num_substitutions_tags], false);
						num_substitutions_tags++;
					}
				}
			}
			fclose(fpsub_read);
		}
	}

    // output in log and progress label
    [progress_label setStringValue:@"Harvesting aliases..."];

    // In order to proper write the @seealso tags in the XML files, we need to harvest all aliases, since they'll have to be treated separately
    num_aliases = 0;
    harvest_aliases(sources_folder1, folder1_recursive, error_log);
    harvest_aliases(sources_folder2, folder2_recursive, error_log);
    harvest_aliases(sources_folder3, folder3_recursive, error_log);
    harvest_aliases(sources_folder4, folder4_recursive, error_log);

//    long count = 0; // number of written elements
	
    // Now we actually process the directories and write all files.
	process_directory(export_XMLs, sources_folder1, folder1_recursive, common_ref_file1, common_ref_file2, common_ref_file3,
                      XML_output_folder, sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
					  progress_label, error_log, 
					  fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
					  library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);

	process_directory(export_XMLs, sources_folder2, folder2_recursive, common_ref_file1, common_ref_file2, common_ref_file3,
                      XML_output_folder, sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
					  progress_label, error_log, 
					  fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
					  library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);

	process_directory(export_XMLs, sources_folder3, folder3_recursive, common_ref_file1, common_ref_file2, common_ref_file3,
                      XML_output_folder, sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
					  progress_label, error_log, 
					  fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
					  library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);

	process_directory(export_XMLs, sources_folder4, folder4_recursive, common_ref_file1, common_ref_file2, common_ref_file3,
                      XML_output_folder, sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
					  progress_label, error_log, 
					  fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
					  library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);
	
    // Filling stats
    {
        long num_objects = 0, num_abstractions = 0;
        for (i = 0; i < NUM_DOCTOR_MAX_MODULE_STATUS; i++) {
            num_objects += stats->num_objects[i];
            num_abstractions += stats->num_abstractions[i];
        }
        [overview_label setStringValue:[NSString stringWithFormat: @"%ld modules parsed.\n • %ld objects (%ld deprecated, %ld experimental, %ld hidden)\n • %ld abstractions (%ld deprecated, %ld experimental, %ld hidden)", stats->num_modules, num_objects, stats->num_objects[k_STATUS_DEPRECATED], stats->num_objects[k_STATUS_EXPERIMENTAL], stats->num_objects[k_STATUS_HIDDEN], num_abstractions, stats->num_abstractions[k_STATUS_DEPRECATED], stats->num_abstractions[k_STATUS_EXPERIMENTAL], stats->num_abstractions[k_STATUS_HIDDEN]]];
        
    }
    
	if (fp_c74contents) {
		fprintf(fp_c74contents,"</root>\n");
		fclose(fp_c74contents);
	}
	
	if (fp_object_qlookup) {
		fprintf(fp_object_qlookup,"\n");
		fprintf(fp_object_qlookup,"}\n");
		fclose(fp_object_qlookup);
	}
	
	for (i = 0; i < MAX_SUBSTITUTIONS; i++)
		free(substitutions_tags[i]);

	if (fp_database)
		fclose(fp_database);
	if (fp_objectlist)
		fclose(fp_objectlist);
	if (fp_objectmappings)
		fclose(fp_objectmappings);
}

int isDirectory(const char *path) {
	struct stat statbuf;
	stat(path, &statbuf);
	return S_ISDIR(statbuf.st_mode);
}

void process_directory(char export_XMLs, char *path, char recursive,
					   char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, char *XML_output_folder,
					   char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
					   NSTextField *progress_label, NSTextView *error_log, 
					   FILE *fp_database, FILE *fp_objectlist, FILE *fp_objectmappings, FILE *fp_object_qlookup, char separate_objs_and_abstrs_in_objlist,
					   char *library_name, FILE *fp_c74contents, char *substitutions_file, char **substitutions_tags, long num_substitutions_tags,
					   t_doctor_max_stats *stats, char *math_category, char add_syntax_before_method_description, char for_bach)
{
	DIR *dir;
	struct dirent *ent;
	if (strlen(path) > 0) {
		if ((dir = opendir (path)) != NULL) {
			/* print all the files and directories within directory */
			while ((ent = readdir (dir)) != NULL) {
				char str[FILENAME_MAX];
				long len;

				if (!strcmp(ent->d_name, "."))
					continue;

				if (!strcmp(ent->d_name, ".."))
					continue;
				
				struct stat st;
				lstat(ent->d_name, &st);
				if(ent->d_type == DT_DIR) {
					if (recursive) {
						char buf[PATH_MAX + 1]; 
						snprintf(buf, PATH_MAX, "%s/%s", path, ent->d_name);
//						realpath(ent->d_name, buf); // buf + 60
						process_directory(export_XMLs, buf, recursive,
										  common_ref_file1, common_ref_file2, common_ref_file3, XML_output_folder,
										  sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
										  progress_label, error_log, 
										  fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
										  library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);
					}
				} else {
					
					strcpy(str, ent->d_name);
					len = strlen(str);
					if ((len > 2 && str[len-1] == 'c' && str[len-2] == '.') || // C file
						(len > 4 && str[len-1] == 'p' && str[len-2] == 'p' && str[len-3] == 'c' && str[len-4] == '.')) { // C++ file
						if (contains_metadata(path, ent->d_name, error_log)) {
							process_file(export_XMLs, path, ent->d_name, common_ref_file1, common_ref_file2, common_ref_file3, XML_output_folder,
										 sort_methods, sort_attributes, export_in_out_as_misc, export_discussion_as_misc,
										 progress_label, error_log, 
										 fp_database, fp_objectlist, fp_objectmappings, fp_object_qlookup, separate_objs_and_abstrs_in_objlist,
										 library_name, fp_c74contents, substitutions_file, substitutions_tags, num_substitutions_tags, stats, math_category, add_syntax_before_method_description, for_bach);
							[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.01]];
						}
					}
				}
			}
			closedir (dir);
		} else {
			/* could not open directory */
			[error_log setString:[NSString stringWithFormat: @"%@ %s %s\n", [error_log string], "Failed to open folder", path]];
		}
	}	
}


void add_alias(char *alias, char *realname)
{
    bool found = false;
    for (long i = 0; i < num_aliases; i++) {
        if (strcmp(alias, harvested_alias[i]) == 0) {
            found = 1;
            break;
        }
    }
            
    if (!found && num_aliases < MAX_ALIASES - 1) {
        strcpy(harvested_alias[num_aliases], alias);
        strcpy(harvested_realname[num_aliases], realname);
        num_aliases++;
    }
}

void harvest_aliases(char *path, char recursive, NSTextView *error_log)
{
    DIR *dir;
    struct dirent *ent;
    if (strlen(path) > 0) {
        if ((dir = opendir (path)) != NULL) {
            /* print all the files and directories within directory */
            while ((ent = readdir (dir)) != NULL) {
                char str[FILENAME_MAX];
                long len;
                
                if (!strcmp(ent->d_name, "."))
                    continue;
                
                if (!strcmp(ent->d_name, ".."))
                    continue;
                
                struct stat st;
                lstat(ent->d_name, &st);
                if(ent->d_type == DT_DIR) {
                    if (recursive) {
                        char buf[PATH_MAX + 1];
                        snprintf(buf, PATH_MAX, "%s/%s", path, ent->d_name);
                        harvest_aliases(buf, recursive, error_log);
                    }
                } else {
                    
                    strcpy(str, ent->d_name);
                    len = strlen(str);
                    if ((len > 2 && str[len-1] == 'c' && str[len-2] == '.') || // C file
                        (len > 4 && str[len-1] == 'p' && str[len-2] == 'p' && str[len-3] == 'c' && str[len-4] == '.')) { // C++ file
                        if (contains_metadata(path, ent->d_name, error_log)) {
                            char fullfilename_read[PATH_MAX];
                            long len_path_read = strlen(path);
                            strcpy(fullfilename_read, path);
                            fullfilename_read[len_path_read] = '/';
                            strcpy(fullfilename_read + len_path_read + 1, ent->d_name);
                            
                            FILE *fp_read = fopen(fullfilename_read, "r");
                            
                            char line[MAX_LINE_CHARS];
                            char name[MAX_SINGLE_ELEM_CHARS];
                            char realname[MAX_SINGLE_ELEM_CHARS];
                            name[0] = realname[0] = 0;
                            while (true) {
                                if (fgets(line, sizeof line, fp_read) == NULL)
                                    break;
                                
                                char *trimmed = lefttrim(line, false);
                                if (trimmed) {
                                    if (strncmp(trimmed, "@name", 5) == 0) {
                                        trimmed = lefttrim(trimmed + 5, false);
                                        while (!trimmed && fgets(line, sizeof line, fp_read) != NULL)
                                            trimmed = lefttrim(line, true);
                                        if (trimmed) {
                                            strncpy(name, trimmed, MAX_SINGLE_ELEM_CHARS-1);
                                            name[MAX_SINGLE_ELEM_CHARS-1] = 0;
                                            righttrim(name, true);
                                            if (realname[0])
                                                break;
                                        }
                                    }
                                    if (strncmp(trimmed, "@realname", 9) == 0) {
                                        trimmed = lefttrim(trimmed + 9, false);
                                        while (!trimmed && fgets(line, sizeof line, fp_read) != NULL)
                                            trimmed = lefttrim(line, true);
                                        if (trimmed) {
                                            strncpy(realname, trimmed, MAX_SINGLE_ELEM_CHARS-1);
                                            realname[MAX_SINGLE_ELEM_CHARS-1] = 0;
                                            righttrim(realname, true);
                                            if (name[0])
                                                break;
                                        }
                                    }
                                }
                            }
                            
                            if (name[0] && realname[0]) {
                                if (strcmp(name, realname) != 0) {
                                    add_alias(name, realname);
                                }
                            }
                            
                            fclose(fp_read);
                            
                        }
                    }
                }
            }
            closedir (dir);
        } else {
            /* could not open directory */
            [error_log setString:[NSString stringWithFormat: @"%@ %s %s\n", [error_log string], "Failed to open folder", path]];
        }
    }
}


char is_string_in_string_array(char *str, char **strarray, long num_elems)
{
	long i;
	for (i = 0; i < num_elems; i++) {
		if (!strncmp(str, strarray[i], strlen(strarray[i])))
			return i; 
	}
	return -1;
}


void tutorial_name_to_filename(const char *tutorial_name, char *tutorial_folder, char *output_name)
{
	DIR *dir;
	struct dirent *ent;
	if (strlen(tutorial_folder) > 0) {
		if ((dir = opendir (tutorial_folder)) != NULL) {
			/* print all the files and directories within directory */
			while ((ent = readdir (dir)) != NULL) {
				char str[FILENAME_MAX];
				long len;
				
				if (!strcmp(ent->d_name, "."))
					continue;
				
				if (!strcmp(ent->d_name, ".."))
					continue;
				
				strcpy(str, ent->d_name);
				len = strlen(str);
				
				if (strstr(ent->d_name, tutorial_name)) {
					char *found = strstr(ent->d_name, ".maxtut");
					if (found) {
						strncpy(output_name, ent->d_name, MAX_SINGLE_ELEM_CHARS);
						output_name[found - ent->d_name] = 0;
					}
				}
			}
			closedir (dir);
		}
	}	
}


void replace_standard(char *buf, long num_chars)
{
    replace_char(buf, num_chars, '&', "&amp;");
    replace_char(buf, num_chars, '<', "&lt;");
    replace_char(buf, num_chars, '>', "&gt;");
    
}

void strncpy_and_replace_standard(char *dest, const char *source, long num_chars)
{
    strncpy(dest, source, num_chars);
    
    replace_standard(dest, num_chars);

}

void check_all_method_example_labels(char *method_example_label[MAX_METHODS][MAX_METHOD_EXAMPLES])
{
    long i, j;
    for (i = 0; i < MAX_METHODS; i++) {
        for (j = 0; j < MAX_METHOD_EXAMPLES; j++) {
            if (strstr(method_example_label[i][j], ";")) {
                if (!strstr(method_example_label[i][j], "&")) {
                    char foo = 1;
                    foo++;
                }
            }
        }
    }
}

void process_file(char export_XMLs, char *path, char *filename, 
				  char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, char *output_folder,
				  char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
				  NSTextField *progress_label, NSTextView *error_log, 
				  FILE *fp_database, FILE *fp_objectlist, FILE *fp_objectmappings, FILE *fp_object_qlookup, char separate_obj_and_abstr_in_objectlist,
				  char *library_name, FILE *fp_c74contents, char *substitutions_file, char **substitutions_tags, long num_substitutions_tags, 
				  t_doctor_max_stats *stats, char *math_category, char add_syntax_before_method_description, char for_bach)
{
	FILE *fp_read, *fp_write, *fp_subread;
	char fullfilename_read[300], fullfilename_write[300];
	char flag_line[MAX_LINE_CHARS];
	long len_path_read = strlen(path);
	long len_path_write = strlen(output_folder);
	char line[MAX_LINE_CHARS];
	char subline[MAX_LINE_CHARS]; // not a sub-line, but the line of the fb_subread file (secondary file)
	long i, j;
	
	strcpy(fullfilename_read, path);
	fullfilename_read[len_path_read] = '/';
	strcpy(fullfilename_read + len_path_read + 1, filename);
	
	// output in log and progress label
	char progress_label_str[FILENAME_MAX + 30];
	sprintf(progress_label_str, "Processing %s...", filename);
	[progress_label setStringValue:[NSString stringWithCString:progress_label_str encoding:NSASCIIStringEncoding]];
	[error_log setString:[NSString stringWithFormat: @"%@ Processing file %s...\n", [error_log string], filename]];
	
	
	fp_read = fopen(fullfilename_read, "r");
	
	if (fp_read == NULL) {
		[error_log setString:[NSString stringWithFormat: @"%@ Failed to open file %s for read.\n", [error_log string], filename]];
		return;
    }
	
	char obj_name[MAX_SINGLE_ELEM_CHARS]; // used name, e.g. "bach.*"
	char obj_realname[MAX_SINGLE_ELEM_CHARS]; // real name, ignoring alias, e.g. "bach.times"
    char obj_hiddenalias[MAX_SINGLE_ELEM_CHARS]; // an additional hidden alias
	char obj_type = k_TYPE_OBJECT;
	char digest[MAX_LINE_CHARS];
	char *description[MAX_DESCRIPTION_LINES];
	char *discussion[MAX_DISCUSSION_LINES];
	char module[MAX_SINGLE_ELEM_CHARS];
    char owner[MAX_SINGLE_ELEM_CHARS];
//	char category[MAX_SINGLE_ELEM_CHARS];
	char author[MAX_SINGLE_ELEM_CHARS];
	char *category[20];
	char *seealso[MAX_SEEALSO_ELEMS];
	char *keyword[MAX_KEYWORDS];
	char status = k_STATUS_OK; // by default the status is ok (if no @status category is detected
    char obj_is_math_operator = false;
    
	long in_loop[MAX_INLETS];
	long out_loop[MAX_OUTLETS];
	char in_type[MAX_INLETS][MAX_SINGLE_ELEM_CHARS];
	char out_type[MAX_OUTLETS][MAX_SINGLE_ELEM_CHARS];
	char in_digest[MAX_INLETS][MAX_LINE_CHARS];
	char *in_description[MAX_INLETS][MAX_DESCRIPTION_LINES];
	char out_digest[MAX_OUTLETS][MAX_LINE_CHARS];
	char *out_description[MAX_OUTLETS][MAX_DESCRIPTION_LINES];
	char arg_digest[MAX_ARGUMENTS][MAX_LINE_CHARS];
	char arg_description[MAX_ARGUMENTS][MAX_DESCRIPTION_LINES][MAX_LINE_CHARS];
	long num_in_description_lines[MAX_INLETS], num_out_description_lines[MAX_OUTLETS];
	
	char arg_name[MAX_ARGUMENTS][MAX_SINGLE_ELEM_CHARS];
	char arg_type[MAX_ARGUMENTS][MAX_SINGLE_ELEM_CHARS];
	char arg_optional[MAX_ARGUMENTS];
	long num_arg_description_lines[MAX_ARGUMENTS];
	
	char method_name[MAX_METHODS][MAX_SINGLE_ELEM_CHARS];
	char method_digest[MAX_METHODS][MAX_LINE_CHARS];
	char *method_description[MAX_METHODS][MAX_DESCRIPTION_LINES];
	char method_arg_name[MAX_METHODS][MAX_METHOD_ARGUMENTS][MAX_SINGLE_ELEM_CHARS];
	char method_arg_type[MAX_METHODS][MAX_METHOD_ARGUMENTS][MAX_SINGLE_ELEM_CHARS];
	char method_arg_optional[MAX_METHODS][MAX_ARGUMENTS];
	long method_num_args[MAX_METHODS];
    long method_num_attrs[MAX_METHODS];
	long num_method_description_lines[MAX_METHODS];
    long method_num_examples[MAX_METHODS];
    char *method_example[MAX_METHODS][MAX_METHOD_EXAMPLES];
    char *method_example_label[MAX_METHODS][MAX_METHOD_EXAMPLES];
    char *method_seealso[MAX_METHODS][MAX_METHOD_SEEALSO_ELEMS];
    long method_num_seealso[MAX_METHODS];
    char method_attr_name[MAX_METHODS][MAX_METHOD_ATTRIBUTES][MAX_SINGLE_ELEM_CHARS];
    char method_attr_type[MAX_METHODS][MAX_METHOD_ATTRIBUTES][MAX_SINGLE_ELEM_CHARS];
    char method_attr_default[MAX_METHODS][MAX_METHOD_ATTRIBUTES][MAX_SINGLE_ELEM_CHARS];
    char method_attr_digest[MAX_METHODS][MAX_METHOD_ATTRIBUTES][MAX_LINE_CHARS];

	char attr_name[MAX_ATTRIBUTES][MAX_SINGLE_ELEM_CHARS];
	char attr_type[MAX_ATTRIBUTES][MAX_SINGLE_ELEM_CHARS];
	long attr_size[MAX_ATTRIBUTES];
	char *attr_description[MAX_ATTRIBUTES][MAX_DESCRIPTION_LINES];
	long num_attr_description_lines[MAX_ATTRIBUTES];
	char attr_basic[MAX_ATTRIBUTES];
	char *attr_category[MAX_ATTRIBUTES];	
	char *attr_label[MAX_ATTRIBUTES];	
	char *attr_style[MAX_ATTRIBUTES];	
	char *attr_default[MAX_ATTRIBUTES];	
	char attr_save[MAX_ATTRIBUTES];	
	char attr_paint[MAX_ATTRIBUTES];
	char attr_undocumented[MAX_ATTRIBUTES];
	
	char has_illustration = false;
	char illustration_caption[MAX_LINE_CHARS];

	char has_palette = false;

	illustration_caption[0] = 0;
	
	for (i = 0; i < MAX_DESCRIPTION_LINES; i++)
		description[i] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	for (i = 0; i < MAX_DISCUSSION_LINES; i++)
		discussion[i] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	for (i = 0; i < MAX_METHODS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			method_description[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
    for (i = 0; i < MAX_METHODS; i++) {
        for (j = 0; j < MAX_METHOD_EXAMPLES; j++) {
            method_example[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
            method_example_label[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
        }
        for (j = 0; j < MAX_METHOD_SEEALSO_ELEMS; j++) {
            method_seealso[i][j] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
        }
    }
 
	for (i = 0; i < MAX_ATTRIBUTES; i++) {
		attr_category[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
		attr_label[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
		attr_style[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
		attr_default[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			attr_description[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	}
	for (i = 0; i < MAX_INLETS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			in_description[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	for (i = 0; i < MAX_OUTLETS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			out_description[i][j] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
	
	
	flag_line[0] = 0;
	
	long num_attr = 0;
	
	
	long num_description_lines = 0, num_discussion_lines = 0, num_see_also_elems = 0, num_keyword_elems = 0, num_categories = 0, num_in = -1, num_out = -1, num_arg = 0, num_method = 0;
	char description_ongoing = 0, discussion_ongoing = 0;
	
	for (i = 0; i < MAX_INLETS; i++) {
		in_digest[i][0] = 0;
		in_type[i][0] = 0;
		in_loop[i] = 0;
		num_in_description_lines[i] = 0;
	}
	for (i = 0; i < MAX_OUTLETS; i++) {
		out_digest[i][0] = 0;
		out_type[i][0] = 0;
		out_loop[i] = 0;
		num_out_description_lines[i] = 0;
	}
	for (i = 0; i < MAX_ARGUMENTS; i++) {
		arg_digest[i][0] = 0;
		arg_optional[i] = 0;
		arg_name[i][0] = 0;
		arg_type[i][0] = 0;
		num_arg_description_lines[i] = 0;
	}
	for (i = 0; i < MAX_METHODS; i++) {
		method_digest[i][0] = 0;
		method_name[i][0] = 0;
		method_num_args[i] = 0;
        method_num_attrs[i] = 0;
        method_num_seealso[i] = 0;
        method_num_examples[i] = 0;
		num_method_description_lines[i] = 0;
        for (j = 0; j < MAX_METHOD_ATTRIBUTES; j++) {
            method_attr_default[i][j][0] = 0;
            method_attr_type[i][j][0] = 0;
            method_attr_name[i][j][0] = 0;
            method_attr_digest[i][j][0] = 0;
        }
        for (j = 0; j < MAX_METHOD_EXAMPLES; j++) {
            method_example_label[i][j][0] = 0;
            method_example[i][j][0] = 0;
        }
        for (j = 0; j < MAX_METHOD_SEEALSO_ELEMS; j++)
            method_seealso[i][j][0] = 0;
	}
	for (i = 0; i < MAX_ATTRIBUTES; i++) {
		attr_name[i][0] = 0;
		attr_basic[i] = 0;
		attr_save[i] = 0;
		attr_category[i][0] = 0;
		attr_label[i][0] = 0;
		strcpy(attr_style[i], "text");
		attr_default[i][0] = 0;
		attr_size[i] = 1;
		attr_type[i][0] = 0;
		attr_undocumented[i] = 0;
		num_attr_description_lines[i] = 0;
	}
	
	
	for (i = 0; i < MAX_SEEALSO_ELEMS; i++)
		seealso[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
	for (i = 0; i < MAX_KEYWORDS; i++)
		keyword[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
	for (i = 0; i < 20; i++)
		category[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
	
	obj_name[0] = obj_realname[0] = digest[0] = module[0] = author[0] = owner[0] = obj_hiddenalias[0] = 0;

	long curr_in = -1, curr_out = -1, curr_arg = -1, curr_method = -1, curr_marg = -1, curr_mattr = -1, curr_attr = -1;
	char active_is_what = 0; // if this is 2 we're writing the inlet, 3 we're writing the outlet, 4 = arguments, 5 = methods, 6 = method arguments, 7 = attribtues, 8 = method attributes
	char header = true;
	
	char curr_category[MAX_SINGLE_ELEM_CHARS];
	char curr_attr_name[MAX_SINGLE_ELEM_CHARS];
	
	curr_category[0] = curr_attr_name[0] = 0;
	
	char parsing_sub_file = false, parsing_substitution_file = false;
	long subs = -1;

	char *lines_to_substitute[MAX_COMMON_REFERENCE_LINES];
	long num_lines_to_substitute = 0;
	long idx_line_to_substitute = -1;
	char substitutionline[MAX_LINE_CHARS];
	
	
	// FIRST OF ALL: find the name of the bach object
	while (true) /* read a line */
	{
		if (parsing_sub_file) {
			if (fgets(subline, sizeof subline, fp_subread) == NULL) {
				parsing_sub_file = false;
				continue;
			}
		} else if (parsing_substitution_file) {
			idx_line_to_substitute++;
			if (idx_line_to_substitute >= num_lines_to_substitute) {
				parsing_substitution_file = false;
				idx_line_to_substitute = -1;
				continue;
			} else {
				strncpy(substitutionline, lines_to_substitute[idx_line_to_substitute], MAX_LINE_CHARS - 1);
			}
		} else {
			if (fgets(line, sizeof line, fp_read) == NULL)
				break;
		}
		
		char found = false;
		char force_add_doc[MAX_SINGLE_ELEM_CHARS];
		char *trimmed = lefttrim(parsing_sub_file ? subline : (parsing_substitution_file ? substitutionline : line), false);
		
		force_add_doc[0] = 0;
		
		if (trimmed) {
			
			if (!parsing_sub_file && !parsing_substitution_file && obj_name[0] == 0 && strncmp(trimmed, "@name", 5) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 5, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					strncpy(obj_name, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
				righttrim(obj_name, true);
				
			} else if (!parsing_sub_file && !parsing_substitution_file && obj_realname[0] == 0 && strncmp(trimmed, "@realname", 9) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 9, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					strncpy(obj_realname, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
				righttrim(obj_realname, true);
				
            } else if (!parsing_sub_file && !parsing_substitution_file && obj_hiddenalias[0] == 0 && strncmp(trimmed, "@hiddenalias", 12) == 0) {
                found = true;
                description_ongoing = discussion_ongoing = 0;
                trimmed = lefttrim(trimmed + 12, false);
                while (!trimmed && fgets(line, sizeof line, fp_read) != NULL)
                    trimmed = lefttrim(line, true);
                if (trimmed)
                    strncpy(obj_hiddenalias, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
                righttrim(obj_hiddenalias, true);

            } else if (!parsing_sub_file && !parsing_substitution_file && module[0] == 0 && strncmp(trimmed, "@module", 7) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 7, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					strncpy(module, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
				
            } else if (!parsing_sub_file && !parsing_substitution_file && owner[0] == 0 && strncmp(trimmed, "@owner", 6) == 0) {
                found = true;
                description_ongoing = discussion_ongoing = 0;
                trimmed = lefttrim(trimmed + 6, false);
                while (!trimmed && fgets(line, sizeof line, fp_read) != NULL)
                    trimmed = lefttrim(line, true);
                if (trimmed)
                    strncpy(owner, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
                
            } else if (!parsing_sub_file && !parsing_substitution_file && strncmp(trimmed, "@type", 5) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 5, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed && strncmp(trimmed, "object", 6) == 0)
					obj_type = k_TYPE_OBJECT;
				else if (trimmed && strncmp(trimmed, "abstraction", 11) == 0)
					obj_type = k_TYPE_ABSTRACTION;

			} else if (!parsing_sub_file && !parsing_substitution_file && strncmp(trimmed, "@status", 7) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 7, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				righttrim(line, true);
				for (i = 0; trimmed[i]; i++)
					trimmed[i] = tolower(trimmed[i]);
				if (strncmp(trimmed, "experimental", 12) == 0)
					status = k_STATUS_EXPERIMENTAL;
				else if (strncmp(trimmed, "hidden", 6) == 0)
					status = k_STATUS_HIDDEN;
				else if (strncmp(trimmed, "deprecated", 10) == 0)
					status = k_STATUS_DEPRECATED;
				else if (strncmp(trimmed, "ok", 2) == 0)
					status = k_STATUS_OK;
				
			} else if (!parsing_sub_file && !parsing_substitution_file && strncmp(trimmed, "@palette", 8) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 8, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed && strncmp(trimmed, "YES", 3) == 0 || strncmp(trimmed, "yes", 3) == 0 || strncmp(trimmed, "Yes", 3) == 0) 
					has_palette = true;
			} else if (!parsing_sub_file && !parsing_substitution_file && strncmp(trimmed, "@illustration", 13) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 13, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed && strncmp(trimmed, "on", 2) == 0) {
					has_illustration = true;
					trimmed = lefttrim(trimmed + 2, false);
					while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
						trimmed = lefttrim(line, true);
					if (trimmed && strncmp(trimmed, "@caption", 8) == 0) {
						trimmed = lefttrim(trimmed + 8, false);
						strncpy(illustration_caption, trimmed, MAX_LINE_CHARS - 1);
					}
				}
			
			} else if (!parsing_sub_file && !parsing_substitution_file && digest[0] == 0 && strncmp(trimmed, "@digest", 7) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 7, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					strncpy(digest, trimmed, MAX_LINE_CHARS - 1);
				
			} else if (!parsing_sub_file && !parsing_substitution_file && author[0] == 0 && strncmp(trimmed, "@author", 7) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 7, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					strncpy(author, trimmed, MAX_SINGLE_ELEM_CHARS - 1);
				
			} else if (!parsing_sub_file && !parsing_substitution_file && num_see_also_elems == 0 && strncmp(trimmed, "@seealso", 8) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 8, false);
				if (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
                
				if (trimmed) {
                    split_string(trimmed, ",", seealso, MAX_SEEALSO_ELEMS, &num_see_also_elems);
                    
                    // more than one seealso line?
                    char breaktwice = false;
                    while (true) {
                        if (fgets(line, sizeof line, fp_read) == NULL) {
                            breaktwice = true;
                            break;
                        } else {
                            char *newtrimmed = lefttrim(line, false);
                            if (newtrimmed && strlen(newtrimmed) >= 1 && newtrimmed[0] != '@' && newtrimmed[0] != '*' && newtrimmed[0] != '/') {
                                char *temp_seealso[MAX_SEEALSO_ELEMS];
                                long temp_num_see_also_elems = 0;
                                long j;
                                for (j = 0; j < MAX_SEEALSO_ELEMS; j++)
                                    temp_seealso[j] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
                                split_string(newtrimmed, ",", temp_seealso, MAX_SEEALSO_ELEMS, &temp_num_see_also_elems);
                                for (j = 0; j < temp_num_see_also_elems && num_see_also_elems < MAX_SEEALSO_ELEMS; j++) {
                                    strncpy(seealso[num_see_also_elems], temp_seealso[j], MAX_SINGLE_ELEM_CHARS - 1);
                                    num_see_also_elems ++;
                                }
                                for (j = 0; j < temp_num_see_also_elems; j++)
                                    free(temp_seealso[j]);
                            } else
                                break;
                        }
                    }
                    if (breaktwice)
                        break;
                }
                
            } else if (!parsing_sub_file && !parsing_substitution_file && num_keyword_elems == 0 && strncmp(trimmed, "@keywords", 9) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 9, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					split_string(trimmed, ",", keyword, MAX_KEYWORDS, &num_keyword_elems);
				
				// more than one keyword line?
				char breaktwice = false;
				while (true) {
					if (fgets(line, sizeof line, fp_read) == NULL) {
						breaktwice = true;
						break;
					} else {
						char *newtrimmed = lefttrim(line, false);
						if (newtrimmed && strlen(newtrimmed) >= 1 && newtrimmed[0] != '@' && newtrimmed[0] != '*' && newtrimmed[0] != '/') {
							char *temp_keyword[MAX_KEYWORDS];
							long temp_num_keyword_elems = 0;
							long j;
							for (j = 0; j < MAX_KEYWORDS; j++)
								temp_keyword[j] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
							split_string(newtrimmed, ",", temp_keyword, MAX_KEYWORDS, &temp_num_keyword_elems);
							for (j = 0; j < temp_num_keyword_elems && num_keyword_elems < MAX_KEYWORDS; j++) {
								strncpy(keyword[num_keyword_elems], temp_keyword[j], MAX_SINGLE_ELEM_CHARS - 1);
								num_keyword_elems ++;
							}
							for (j = 0; j < temp_num_keyword_elems; j++)
								free(temp_keyword[j]);
						} else 
							break;
					}
				}
				if (breaktwice)
					break; 
			
			} else if (!parsing_sub_file && !parsing_substitution_file && num_see_also_elems == 0 && strncmp(trimmed, "@category", 9) == 0) {
				found = true;
				description_ongoing = discussion_ongoing = 0;
				trimmed = lefttrim(trimmed + 9, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) 
					split_string(trimmed, ",", category, 20, &num_categories);
			} else if (!parsing_sub_file && !parsing_substitution_file && num_description_lines == 0 && strncmp(trimmed, "@description", 12) == 0) {
				found = true;
				trimmed = lefttrim(trimmed + 12, false);
				while (!trimmed && fgets(line, sizeof line, fp_read) != NULL) 
					trimmed = lefttrim(line, true);
				if (trimmed) {
					description_ongoing = 1;
					num_description_lines = 0;
					found = false; // so that the description continues
				}
			} else if (!parsing_sub_file && !parsing_substitution_file && num_discussion_lines == 0 && strncmp(trimmed, "@discussion", 11) == 0) {
				found = true;
				trimmed = lefttrim(trimmed + 11, false);
				if (!trimmed)
					if (fgets(line, sizeof line, fp_read) != NULL) 
						trimmed = lefttrim(line, true);
				if (trimmed) {
					discussion_ongoing = 1;
					num_discussion_lines = 0;
					found = false; // so that the description continues
				}
			} else if (!parsing_sub_file && !parsing_substitution_file && header && (strncmp(trimmed, "typedef", 7) == 0 || strncmp(trimmed, "*/", 2) == 0)) {
				header = false;
				
			// Used by DADA's FLAGS: this is the "flag" line
			} else if (!parsing_sub_file && strncmp(trimmed, "dadaobj_class_init", 18) == 0) {
				strcpy(flag_line, trimmed);
                
                replace_substring(flag_line, MAX_LINE_CHARS, "DADAOBJ_BBGIMAGE", "DADAOBJ_BORDER | DADAOBJ_BG | DADAOBJ_BGIMAGE");
                replace_substring(flag_line, MAX_LINE_CHARS, "DADAOBJ_BBG", "DADAOBJ_BORDER | DADAOBJ_BG");
                replace_substring(flag_line, MAX_LINE_CHARS, "DADAOBJ_CENTEROFFSET", "DADAOBJ_CENTEROFFSETX | DADAOBJ_CENTEROFFSETY");
                replace_substring(flag_line, MAX_LINE_CHARS, "DADAOBJ_ZOOM", "DADAOBJ_ZOOMX | DADAOBJ_ZOOMY");

				fp_subread = fopen(SOURCES_PATH_DADA_OBJ_COMMONS, "r");
				
				if (fp_subread == NULL) {
					[error_log setString:[NSString stringWithFormat: @"%@ Failed to open dada.object.c for read.\n", [error_log string]]];
				} else {
					parsing_sub_file = true;
				}

                
			} else if (strncmp(trimmed, "CLASS_STICKY_ATTR", 17) == 0) { // was: 18: WHY?
				char *temp1 = strstr(trimmed, "\"");
				if (temp1 && strncmp(temp1+1, "category", 8) == 0) {
					char *temp2 = strstr(temp1 + 1, ")");
					if (temp2) {
						char this_category[MAX_LINE_CHARS];
						char *temp3 = temp2;
						temp3--;
						temp3--;
						while (temp3 > temp1 && temp3[0] != '"')
							temp3--;
						strcpy(this_category, temp3+1);
						this_category[temp2 - temp3 - 2] = 0;
						strcpy(curr_category, this_category);
					}
				}
				
			} else if (!parsing_sub_file && !parsing_substitution_file && ((subs = is_string_in_string_array(trimmed, substitutions_tags, num_substitutions_tags)) >= 0)) {
				// we can substitute line with something in the substitutions file
				if (!obtain_common_reference(substitutions_tags[subs], lines_to_substitute, &num_lines_to_substitute, substitutions_file, NULL, NULL, NULL, error_log, false, false))
					[error_log setString:[NSString stringWithFormat: @"%@ • Reference %s could not be found.\n", [error_log string], substitutions_tags[subs]]];
				else {
					idx_line_to_substitute = -1;
					parsing_substitution_file = true;
					continue;
				}
			} else if (!parsing_sub_file && strncmp(trimmed, "llllobj_class_add_out_attr", 26) == 0) { // @out attribute
				char *retrim = lefttrim(trimmed + 29, false);
				char is_ui = strncmp(retrim, "LLLL_OBJ_UI", 11);
				
				// retrieve index
				curr_attr = -1;
				for (i = 0; i < num_attr; i++) {
					if (strcmp(attr_name[i], "out") == 0) {
						curr_attr = i;
						break;
					}
				}
				if (curr_attr == -1 && num_attr >= MAX_ATTRIBUTES) {
					// nothing to do, too many attributes
				} else {
					if (curr_attr == -1) {
						curr_attr = num_attr;
						num_attr ++;
						strcpy(attr_name[curr_attr], "out");
					}
					attr_basic[curr_attr] = 1;
					strcpy(attr_category[curr_attr], "Behavior");
					strcpy(attr_label[curr_attr], "Outlet Types");
					strcpy(attr_style[curr_attr], "text");
					strcpy(attr_type[curr_attr], "symbol");
					if (is_ui)
						attr_save[curr_attr] = 1;
					
					num_attr_description_lines[curr_attr] = 0;
					description_ongoing = 7;
					found = false;
					strcpy(force_add_doc, "BACH_DOC_OUT");
				}
			} else if (!parsing_sub_file && strncmp(trimmed, "notation_class_add_notation_attributes", 38) == 0) { // Gotta parse the notation attributes
				fp_subread = fopen(SOURCES_PATH_NOTATION_MAXINTERFACE, "r");
				
				if (fp_subread == NULL) {
					[error_log setString:[NSString stringWithFormat: @"%@ Failed to open notation_maxinterface.c for read.\n", [error_log string]]];
				} else {
					parsing_sub_file = true;
				}
				
			} else if (strncmp(trimmed, "CLASS_ATTR_", 11) == 0) {
				// attribute!
				// retrieving name.
				char this_attr_name[MAX_LINE_CHARS];
				char *temp1 = get_next_double_quotes(trimmed, true);
				if (temp1) {
					char *temp2 = strstr(temp1 + 1, "\"");
					if (temp2) {
						strcpy(this_attr_name, temp1 + 1);
						this_attr_name[temp2 - temp1 - 1] = 0;
						// retrieve index
						curr_attr = -1;
						for (i = 0; i < num_attr; i++) {
							if (strcmp(this_attr_name, attr_name[i]) == 0) {
								curr_attr = i;
								break;
							}
						}
						if (curr_attr == -1 && num_attr >= MAX_ATTRIBUTES) {
							// nothing to do, too many attributes
						} else {
							if (curr_attr == -1) {
								curr_attr = num_attr;
								num_attr ++;
								strcpy(attr_name[curr_attr], this_attr_name);
							}
							
							active_is_what = 7; // attribute
							
							if (strncmp(trimmed + 11, "LABEL", 5) == 0) {
								char *temp3 = strstr(temp2 + 1, "\"");
								if (temp3) {
									char this_attr_label[MAX_LINE_CHARS];
									char *temp4 = get_next_double_quotes(temp3 + 1, true);
									strcpy(this_attr_label, temp3 + 1);
									this_attr_label[temp4 - temp3 - 1] = 0;
									strncpy(attr_label[curr_attr], this_attr_label, MAX_SINGLE_ELEM_CHARS - 1);
								}
							} else if (strncmp(trimmed + 11, "ENUMINDEX", 9) == 0) {
								strncpy(attr_style[curr_attr], "enumindex", MAX_SINGLE_ELEM_CHARS - 1);
								// possibly to do: add information about each enumindex element
							} else if (strncmp(trimmed + 11, "STYLE", 5) == 0) {
								if (strncmp(trimmed + 11, "STYLE_LABEL", 11) == 0) {
									//									char *temp5 = strstr(temp1 + 1, ")");
									
									char *temp5 = &temp1[strlen(temp1)-1];
									while (temp5) {
										if (*temp5 == ')') {
											break;
										}
										temp5--;
										if (temp5 == temp1) {
											temp5 = NULL;
											break;
										}
									}
									
									if (temp5) {
										char this_label[MAX_LINE_CHARS];
										char *temp6 = temp5;
										temp6--;
										temp6--;
										while (temp6 > trimmed + 11 && temp6[0] != '"')
											temp6--;
										strcpy(this_label, temp6 + 1);
										this_label[temp5 - temp6 - 2] = 0;
										if (strcmp(attr_name[curr_attr], "playstep") == 0) {
											char foo = 6;
											foo++;
										}
										strcpy(attr_label[curr_attr], this_label);
									}
								}
								char *temp3 = strstr(temp2 + 1, "\"");
								if (temp3) {
									char this_attr_style[MAX_LINE_CHARS];
									char *temp4 = strstr(temp3 + 1, "\"");
									strcpy(this_attr_style, temp3 + 1);
									this_attr_style[temp4 - temp3 - 1] = 0;
									strncpy(attr_style[curr_attr], this_attr_style, MAX_SINGLE_ELEM_CHARS - 1);
								}
							} else if (strncmp(trimmed + 11, "CATEGORY", 8) == 0) {
								char *temp3 = strstr(temp2 + 1, "\"");
								if (temp3) {
									char this_attr_category[MAX_LINE_CHARS];
									char *temp4 = strstr(temp3 + 1, "\"");
									strcpy(this_attr_category, temp3 + 1);
									this_attr_category[temp4 - temp3 - 1] = 0;
									strncpy(attr_category[curr_attr], this_attr_category, MAX_SINGLE_ELEM_CHARS - 1);
								}
							} else if (strncmp(trimmed + 11, "DEFAULT", 7) == 0) {
								if (strncmp(trimmed + 11, "DEFAULT_SAVE_PAINT", 18) == 0) {
									attr_save[curr_attr] = 1;
									attr_paint[curr_attr] = 1;
								} else if (strncmp(trimmed + 11, "DEFAULT_PAINT", 13) == 0) {
									attr_paint[curr_attr] = 1;
								} else if (strncmp(trimmed + 11, "DEFAULT_SAVE", 12) == 0) {
									attr_save[curr_attr] = 1;
								}
								char *temp3 = strstr(temp2 + 1, "\"");
								if (temp3) {
									char this_attr_default[MAX_LINE_CHARS];
									char *temp4 = strstr(temp3 + 1, "\"");
									if (temp4) {
										long tmp_int = temp3[1] == '<' ? 2 : 1;		// removing "<" and ">" like in "<none>". 
										strcpy(this_attr_default, temp3 + tmp_int);
										this_attr_default[temp4 - temp3 - tmp_int] = 0;
										if (temp4 - temp3 - tmp_int - 1 >= 0 && this_attr_default[temp4 - temp3 - tmp_int - 1] == '>')
											this_attr_default[temp4 - temp3 - tmp_int - 1] = 0;
										strncpy(attr_default[curr_attr], this_attr_default, MAX_SINGLE_ELEM_CHARS - 1);
									}
								}
							} else if (strncmp(trimmed + 11, "BASIC", 5) == 0) {
								attr_basic[curr_attr] = 1;
							} else if (strncmp(trimmed + 11, "SAVE", 4) == 0) {
								attr_save[curr_attr] = 1;
							} else if (strncmp(trimmed + 11, "PAINT", 5) == 0) {
								attr_save[curr_attr] = 1;
							} else if (strncmp(trimmed + 11, "INVISIBLE", 9) == 0) {
								// we used to set attr_undocumented[curr_attr] = 1,
								// yet we might perfectly want to document invisible attributes
								// Thus, we just do nothing.
							} else {
								char found_attr = false;
								char gotta_set_length = false;
								// All the NOTATIONOBJ_ stuff is needed for proper parsing of 
								// bach attribute system
								if (strncmp(trimmed + 11, "LONG_ARRAY", 10) == 0) {
									strcpy(attr_type[curr_attr], "int_array");
									found_attr = true;
									gotta_set_length = true;
                                } else if (strncmp(trimmed + 11, "DOUBLE_ARRAY", 12) == 0) {
                                    strcpy(attr_type[curr_attr], "float_array");
                                    found_attr = true;
                                    gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "SYM_ARRAY", 9) == 0) {
									strcpy(attr_type[curr_attr], "sym_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "ATOM_ARRAY", 9) == 0) {
									strcpy(attr_type[curr_attr], "atom_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "CHAR_VARSIZE", 12) == 0 ||
										   strncmp(trimmed + 11, "NOTATIONOBJ_CHARPTR", 19) == 0) {
									strcpy(attr_type[curr_attr], "char_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "LONG_VARSIZE", 12) == 0 ||
										   strncmp(trimmed + 11, "NOTATIONOBJ_LONGPTR", 19) == 0) {
									strcpy(attr_type[curr_attr], "int_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "FLOAT_VARSIZE", 13) == 0) {
									strcpy(attr_type[curr_attr], "float_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "DOUBLE_VARSIZE", 14) == 0 ||
										   strncmp(trimmed + 11, "NOTATIONOBJ_DBLPTR", 18) == 0) {
									strcpy(attr_type[curr_attr], "float_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "SYM_VARSIZE", 11) == 0 ||
										   strncmp(trimmed + 11, "NOTATIONOBJ_SYMPTR", 18) == 0) {
									strcpy(attr_type[curr_attr], "sym_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "ATOM_VARSIZE", 12) == 0 ||
										   strncmp(trimmed + 11, "NOTATIONOBJ_ATOMPTR", 19) == 0) {
									strcpy(attr_type[curr_attr], "atom_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "OBJ_VARSIZE", 11) == 0) {
									strcpy(attr_type[curr_attr], "obj_array");
									found_attr = true;
									gotta_set_length = true;
								} else if (strncmp(trimmed + 11, "LONG", 4) == 0) {
									strcpy(attr_type[curr_attr], "int");
									found_attr = true;
                                } else if (strncmp(trimmed + 11, "ATOM_LONG", 9) == 0) {
                                    strcpy(attr_type[curr_attr], "int");
                                    found_attr = true;
								} else if (strncmp(trimmed + 11, "CHAR", 4) == 0) {
									strcpy(attr_type[curr_attr], "int");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "FLOAT", 5) == 0) {
									strcpy(attr_type[curr_attr], "float");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "DOUBLE", 6) == 0) {
									strcpy(attr_type[curr_attr], "float");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "SYM", 3) == 0) {
									strcpy(attr_type[curr_attr], "symbol");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "ATOM", 4) == 0) {
									strcpy(attr_type[curr_attr], "atom");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "LLLL", 4) == 0) {
									strcpy(attr_type[curr_attr], "llll");
									found_attr = true;
								} else if (strncmp(trimmed + 11, "OBJ", 4) == 0) {
									strcpy(attr_type[curr_attr], "obj");
									found_attr = true;
                                } else if (strncmp(trimmed + 11, "RGBA_PREVIEW", 12) == 0) {
                                    strcpy(attr_type[curr_attr], "rgba");
                                    found_attr = true;
                                } else if (strncmp(trimmed + 11, "RGBA", 4) == 0) {
                                    strcpy(attr_type[curr_attr], "rgba");
                                    found_attr = true;
								}
								
								if (found_attr) 
									strcpy(attr_category[curr_attr], curr_category);
								
								if (gotta_set_length) {
									char *closed_bracked = strstr(trimmed, ")");
									char *before = closed_bracked;
									if (before) {
										before --;
										while (before > trimmed && before[0] >= '0' && before[0] <= '9')
											before--;
										char before_str[MAX_LINE_CHARS];
										strcpy(before_str, before);
										before_str[closed_bracked - before - 1] = 0;
										long size = atoi(before_str);
										attr_size[curr_attr] = size;
									}
								}
							}
							
						}
					}
				}
			} else if (!header) {
				trimmed = strstr(trimmed, "//"); // must be inside a comment
				
				char *temp;
				if (trimmed) {
					char just_found_inlet_or_outlet = false;

					// exclude something?
					temp = strstr(trimmed, "@exclude");
					if (temp) {
						if (strstr(temp +8, obj_name) || (strlen(temp + 9) >= 3 && (*(temp+12) == 0 || *(temp+12) == '\n' || *(temp+12) == '\r') && strncmp(temp + 9, "all", 3) == 0))
							if (curr_attr > -1 && curr_attr < MAX_ATTRIBUTES)
								attr_undocumented[curr_attr] = true; // excluded! needed for notation_maxinterface.c
						found = true;
					}

					// only include it if the object was flagged with some flags??
					temp = strstr(trimmed, "@includeifflagged");
					if (temp) {
						if (flag_line[0] != 0) {
							// checking all flags
							char *temp2 = temp + 17;
							while (temp2 && *temp2 == ' ')
								temp2++;
							char *pch;
							char this_entry[MAX_LINE_CHARS];
							char all_found = true;
							pch = strtok (temp2,"+");
							while (pch != NULL)
							{
								strcpy(this_entry, pch);
								righttrim(this_entry, false);
								if (!strstr(flag_line, this_entry)) {
									all_found = false;
									break;
								}
								pch = strtok (NULL, "+");
							}
							
							if (all_found)
								attr_undocumented[curr_attr] = true; // excluded! needed for dada
						}
						found = true;
					}

					
					
					// inlets?
					temp = strstr(trimmed, "@in");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 3, false);
						
						char in_as_str[30];
						strncpy(in_as_str, trimmed, 29);
						righttrim(in_as_str, 1);
						curr_in = atoi(in_as_str);
						if (curr_in > num_in)
							num_in = curr_in;
						active_is_what = 2; // inlet
						just_found_inlet_or_outlet = true;
					}
					
					// outlets?
					temp = strstr(trimmed, "@out");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 4, false);
						found = true;
						
						char out_as_str[30];
						strncpy(out_as_str, trimmed, 29);
						righttrim(out_as_str, 1);
						curr_out = atoi(out_as_str);
						if (curr_out > num_out)
							num_out = curr_out;
						active_is_what = 3; // outlet
						just_found_inlet_or_outlet = true;
					}
					
					// family of inlets/outlets? Looped inlets/outlets.
					// E.g. bach.iter has two outets which are looped
					if (just_found_inlet_or_outlet && (active_is_what == 2 || active_is_what == 3)) {
						temp = strstr(trimmed, "@loop");
						if (temp) {
							trimmed = lefttrim(temp + 5, false);
							
							char as_str[30];
							strncpy(as_str, trimmed, 29);
							righttrim(as_str, 1);
							long loop_idx = atoi(as_str);
							
							if (active_is_what == 2)
								in_loop[curr_in] = loop_idx;
							else
								out_loop[curr_out] = loop_idx;
						}
					}
					
					
					// type?
					if (just_found_inlet_or_outlet && (active_is_what == 2 || active_is_what == 3)) {
						temp = strstr(trimmed, "@type");
						if (temp) {
							trimmed = lefttrim(temp + 5, false);
							strncpy(active_is_what == 2 ? in_type[curr_in] : out_type[curr_out], trimmed, MAX_SINGLE_ELEM_CHARS - 1);
							righttrim(active_is_what == 2 ? in_type[curr_in] : out_type[curr_out], 1);
							trimmed += strlen(active_is_what == 2 ? in_type[curr_in] : out_type[curr_out]);
						}
					}
					
					// arguments?
					temp = strstr(trimmed, "@arg");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 4, false);
						
						char arg_as_str[30];
						strncpy(arg_as_str, trimmed, 29);
						righttrim(arg_as_str, 1);
						
						trimmed = trimmed + strlen(arg_as_str);
						
						curr_arg = atoi(arg_as_str);
						if (curr_arg + 1 > num_arg)
							num_arg = curr_arg + 1;
						active_is_what = 4; // arguments
						
						if (curr_arg >= 0 && curr_arg < MAX_ARGUMENTS) {
							char *temp1;
							
							temp1 = strstr(trimmed, "@name");
							if (temp1) {
								temp1 = lefttrim(temp1 + 5, false);
								char name_str[MAX_LINE_CHARS];
								strncpy(name_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(name_str, true);
								strncpy(arg_name[curr_arg], name_str, MAX_SINGLE_ELEM_CHARS - 1);
							}
							
							temp1 = strstr(trimmed, "@type");
							if (temp1) {
								temp1 = lefttrim(temp1 + 5, false);
								char type_str[MAX_LINE_CHARS];
								strncpy(type_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(type_str, true);
								strncpy(arg_type[curr_arg], type_str, MAX_SINGLE_ELEM_CHARS - 1);
							}
							
							temp1 = strstr(trimmed, "@optional");
							if (temp1) {
								temp1 = lefttrim(temp1 + 9, false);
								char opt_str[MAX_LINE_CHARS];
								strncpy(opt_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(opt_str, true);
								arg_optional[curr_arg] = (atoi(opt_str) != 0 ? 1 : 0);
							}
						}
					}
					
                    
					// method arguments?
					temp = strstr(trimmed, "@marg");
					if (temp && curr_method >= 0 && curr_method < MAX_METHODS) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 5, false);
						
						char marg_as_str[30];
						strncpy(marg_as_str, trimmed, 29);
						righttrim(marg_as_str, 1);
						
						trimmed = trimmed + strlen(marg_as_str);
						
						curr_marg = atoi(marg_as_str);
						if (curr_marg + 1 > method_num_args[curr_method])
							method_num_args[curr_method] = curr_marg + 1; // 1-based
						
						active_is_what = 6; // method arguments
						
						if (curr_marg >= 0 && curr_marg < MAX_METHOD_ARGUMENTS) {
							char *temp1;
							
							temp1 = strstr(trimmed, "@name");
							if (temp1) {
								temp1 = lefttrim(temp1 + 5, false);
								char name_str[MAX_LINE_CHARS];
								strncpy(name_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(name_str, true);
								strncpy(method_arg_name[curr_method][curr_marg], name_str, MAX_SINGLE_ELEM_CHARS - 1);
							}
							
							temp1 = strstr(trimmed, "@type");
							if (temp1) {
								temp1 = lefttrim(temp1 + 5, false);
								char type_str[MAX_LINE_CHARS];
								strncpy(type_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(type_str, true);
								strncpy(method_arg_type[curr_method][curr_marg], type_str, MAX_SINGLE_ELEM_CHARS - 1);
							}
							
							temp1 = strstr(trimmed, "@optional");
							if (temp1) {
								temp1 = lefttrim(temp1 + 9, false);
								char opt_str[MAX_LINE_CHARS];
								strncpy(opt_str, temp1, MAX_LINE_CHARS - 1);
								righttrim(opt_str, true);
								method_arg_optional[curr_method][curr_marg] = (atoi(opt_str) != 0 ? 1 : 0);
							}
						}
					}
                    
                    
                    // method attributes?
                    temp = strstr(trimmed, "@mattr");
                    if (temp && curr_method >= 0 && curr_method < MAX_METHODS) {
                        description_ongoing = discussion_ongoing = 0;
                        found = true;
                        
                        trimmed = lefttrim(temp + 6, false);
                        
                        curr_mattr = method_num_attrs[curr_method];
                        
                        active_is_what = 8; // method attributes
                        
                        if (curr_mattr >= 0 && curr_mattr < MAX_METHOD_ATTRIBUTES) {
                            char *temp1;
                            
                            method_num_attrs[curr_method]++;
                            
                            // name
                            char mattr_name_str[MAX_LINE_CHARS];
                            strncpy(mattr_name_str, trimmed, MAX_LINE_CHARS - 1);
                            righttrim(mattr_name_str, true);
                            strncpy(method_attr_name[curr_method][curr_mattr], mattr_name_str, MAX_SINGLE_ELEM_CHARS - 1);
                            
                            temp1 = strstr(trimmed, "@type");
                            if (temp1) {
                                temp1 = lefttrim(temp1 + 5, false);
                                char type_str[MAX_LINE_CHARS];
                                strncpy(type_str, temp1, MAX_LINE_CHARS - 1);
                                righttrim(type_str, true);
                                strncpy(method_attr_type[curr_method][curr_mattr], type_str, MAX_SINGLE_ELEM_CHARS - 1);
                            }
                            
                            temp1 = strstr(trimmed, "@default");
                            if (temp1) {
                                temp1 = lefttrim(temp1 + 8, false);
                                char default_str[MAX_LINE_CHARS];
                                strncpy(default_str, temp1, MAX_LINE_CHARS - 1);
                                righttrim_with_at(default_str);
                                righttrim(default_str, true);
                                strncpy(method_attr_default[curr_method][curr_mattr], default_str, MAX_SINGLE_ELEM_CHARS - 1);
                            }
                            
                            temp1 = strstr(trimmed, "@digest");
                            if (temp1) {
                                temp1 = lefttrim(temp1 + 7, false);
                                char digest_str[MAX_LINE_CHARS];
                                strncpy(digest_str, temp1, MAX_LINE_CHARS - 1);
                                righttrim(digest_str, false);
                                strncpy(method_attr_digest[curr_method][curr_mattr], digest_str, MAX_LINE_CHARS - 1);
                            }

                            
                        }
                    }
					
					
					// methods?
					temp = strstr(trimmed, "@method");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 7, false);
						found = true;
						
						if (num_method < MAX_METHODS) {
							
							char this_method_name[30];
							strncpy(this_method_name, trimmed, 29);
							righttrim(this_method_name, 1);
							
							curr_method = num_method;
							num_method++;
							
							strncpy(method_name[curr_method], this_method_name, MAX_SINGLE_ELEM_CHARS - 1);
							
							trimmed = trimmed + strlen(this_method_name);
							
							active_is_what = 5; // methods
						}
					}
					
					temp = strstr(trimmed, "@digest");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 7, false);
						while (!trimmed && fgets(parsing_sub_file ? subline : (parsing_substitution_file ? substitutionline : line), parsing_sub_file ? (sizeof subline) : (parsing_substitution_file ? (sizeof substitutionline) : (sizeof line)), fp_read) != NULL) 
							trimmed = lefttrim(parsing_sub_file ? subline : (parsing_substitution_file ? substitutionline : line), true);
                        if (trimmed) {
							if (active_is_what == 2 && curr_in >= 0 && curr_in < MAX_INLETS)
								strncpy(in_digest[curr_in], trimmed, MAX_LINE_CHARS - 1);
                            else if (active_is_what == 3 && curr_out >= 0 && curr_out < MAX_OUTLETS)
								strncpy(out_digest[curr_out], trimmed, MAX_LINE_CHARS - 1);
							else if (active_is_what == 4 && curr_arg >= 0 && curr_arg < MAX_ARGUMENTS)
								strncpy(arg_digest[curr_arg], trimmed, MAX_LINE_CHARS - 1);
							else if (active_is_what == 5 && curr_method >= 0 && curr_method < MAX_METHODS)
								strncpy(method_digest[curr_method], trimmed, MAX_LINE_CHARS - 1);
                        }
					}
                    
                    temp = strstr(trimmed, "@example");
                    if (temp) {
                        description_ongoing = discussion_ongoing = 0;
                        found = true;
                        
                        if (method_num_examples[curr_method] < MAX_METHOD_EXAMPLES) {
                            long ex_idx = method_num_examples[curr_method];
                            
                            trimmed = lefttrim(temp + 8, false);
                            
                            if (trimmed) {
                                char *caption = strstr(trimmed, "@caption");
                                if (caption) {
                                    char *caption_trimmed = lefttrim(caption + 8, false);
                                    
                                    strncpy(method_example_label[curr_method][ex_idx], caption_trimmed, MAX_LINE_CHARS - 1);
                                    
                                    long len = MIN(caption - trimmed, MAX_LINE_CHARS - 1);
                                    strncpy(method_example[curr_method][ex_idx], trimmed, len);
                                    method_example[curr_method][ex_idx][len] = 0;
                                } else {
                                    // no caption
                                    strncpy(method_example[curr_method][ex_idx], trimmed, MAX_LINE_CHARS - 1);
                                }
                                method_num_examples[curr_method]++;
                            }
                        }
                    }
                    
                    temp = strstr(trimmed, "@seealso"); // method see also
                    if (temp && curr_method >= 0) {
                        found = true;
                        description_ongoing = discussion_ongoing = 0;
                        trimmed = lefttrim(temp + 8, false);
                        split_string(trimmed, ",", method_seealso[curr_method], MAX_METHOD_SEEALSO_ELEMS, &method_num_seealso[curr_method]);
                    }

					
					temp = strstr(trimmed, "@description");
					if (temp) {
						description_ongoing = discussion_ongoing = 0;
						found = true;
						
						trimmed = lefttrim(temp + 12, false);
						while (!trimmed && fgets(parsing_sub_file ? subline : (parsing_substitution_file ? substitutionline : line), parsing_sub_file ? (sizeof subline) : (parsing_substitution_file ? (sizeof substitutionline) : (sizeof line)), fp_read) != NULL) 
							trimmed = lefttrim(parsing_sub_file ? subline : (parsing_substitution_file ? substitutionline : line), true);
						if (trimmed) {
							if (active_is_what == 2 && curr_in >= 0 && curr_in < MAX_INLETS) {
								found = false; // so that the description continues
								num_in_description_lines[curr_in] = 0;
								description_ongoing = 2;
							} else if (active_is_what == 3 && curr_out >= 0 && curr_out < MAX_OUTLETS) {
								found = false; // so that the description continues
								num_out_description_lines[curr_out] = 0;
								description_ongoing = 3;
							} else if (active_is_what == 4 && curr_arg >= 0 && curr_arg < MAX_ARGUMENTS) {
								found = false; // so that the description continues
								num_arg_description_lines[curr_arg] = 0;
								description_ongoing = 4;
							} else if (active_is_what == 5 && curr_method >= 0 && curr_method < MAX_METHODS) {
								found = false; // so that the description continues
								num_method_description_lines[curr_method] = 0;
								description_ongoing = 5;
							} else if (active_is_what == 7 && curr_attr >= 0 && curr_attr < MAX_ATTRIBUTES) {
								found = false; // so that the description continues
								num_attr_description_lines[curr_attr] = 0;
								description_ongoing = 7;
							}
						}
					}
				}
				
			}
			
			if (!found) {
				if (!trimmed)
					description_ongoing = discussion_ongoing = 0;
				else if (description_ongoing && trimmed[0] != '*') {
					long num_lines = 0;
					
					if (description_ongoing == 1)
						num_lines = num_description_lines;
					else if (description_ongoing == 2)
						num_lines = num_in_description_lines[curr_in];
					else if (description_ongoing == 3)
						num_lines = num_out_description_lines[curr_out];
					else if (description_ongoing == 4)
						num_lines = num_arg_description_lines[curr_arg];
					else if (description_ongoing == 5)
						num_lines = num_method_description_lines[curr_method];
					else if (description_ongoing == 7)
						num_lines = num_attr_description_lines[curr_attr];
					
					if (num_lines >= MAX_DESCRIPTION_LINES)
						description_ongoing = 0;
					else {
						trimmed = lefttrim(trimmed, num_lines == 0 ? false : true);
						if (!trimmed)
							description_ongoing = 0;
						else {
							char *lines_to_add[MAX_COMMON_REFERENCE_LINES];
							long num_lines_to_add = 0;
							
							if (force_add_doc[0] != 0 || strncmp(trimmed, "@copy", 5) == 0) {
								long offset = 5;
								char dont_copy = false;
								if (strncmp(trimmed, "@copyif ", 8) == 0) {
									char temp[MAX_SINGLE_ELEM_CHARS];
									long temp_len = strlen(obj_name);
									strncpy(temp, obj_name, MAX_SINGLE_ELEM_CHARS - 1);
									temp[temp_len] = ' ';
									temp[temp_len+1] = 0;
									if (strncmp(lefttrim(trimmed + 8, false), temp, temp_len+1) != 0) {
										dont_copy = true;
									}
									offset = 8 + temp_len;
								} 
								if (!dont_copy) {
									char name[MAX_SINGLE_ELEM_CHARS];
									strncpy(name, force_add_doc[0] != 0 ? force_add_doc : lefttrim(trimmed + offset, false), MAX_SINGLE_ELEM_CHARS - 1);
									righttrim(name, true);
									recursion_depth = 0;
									if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file1, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
										if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file2, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
                                            if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file3, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
                                                [error_log setString:[NSString stringWithFormat: @"%@ • Reference %s could not be found.\n", [error_log string], name]];
									
									// Setting _NAME variable value
									long j;
									for (j = 0; j < num_lines_to_add; j++) {
										char *pos = strstr(lines_to_add[j], "_NAME");
										char foo;
										foo = 7;
										if (pos && 
											(pos == lines_to_add[j] || *(pos-1) == '>' || *(pos-1) == '/' || *(pos - 1) == ' ') && 
											(*(pos+5) == 0 || *(pos+5) == ' '|| *(pos+5) == '/' || *(pos+5) == '<')) {
											char *cpy = strdup(pos+5);
											
											snprintf(pos, MAX_DESCRIPTION_LINES - (pos-lines_to_add[j]) - 1, "%s%s", obj_name, cpy);
											free(cpy);
										}
									}
									
								}
							} else {
								lines_to_add[0] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
								strncpy(lines_to_add[0], trimmed, MAX_LINE_CHARS - 1);
								num_lines_to_add = 1;
							}
							
							//							printf("Num lines to add: %ld, description_ongoing = %d\n", num_lines_to_add, description_ongoing);
							for (i = 0; i < num_lines_to_add && num_lines < MAX_DESCRIPTION_LINES; i++, num_lines++) {
								if (description_ongoing == 1) {
									strncpy(description[num_description_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(description[num_description_lines], 0);
									num_description_lines++;
								} else if (description_ongoing == 2) {
									strncpy(in_description[curr_in][num_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(in_description[curr_in][num_lines], 0);
									num_in_description_lines[curr_in]++;
								} else if (description_ongoing == 3) {
									strncpy(out_description[curr_out][num_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(out_description[curr_out][num_lines], 0);
									num_out_description_lines[curr_out]++;
								} else if (description_ongoing == 4) {
									strncpy(arg_description[curr_arg][num_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(arg_description[curr_arg][num_lines], 0);
									num_arg_description_lines[curr_arg]++;
								} else if (description_ongoing == 5) {
									strncpy(method_description[curr_method][num_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(method_description[curr_method][num_lines], 0);
									num_method_description_lines[curr_method]++;
								} else if (description_ongoing == 7) {
									strncpy(attr_description[curr_attr][num_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
									righttrim(attr_description[curr_attr][num_lines], 0);
									num_attr_description_lines[curr_attr]++;
								}
							}
							
							for (i = 0; i < num_lines_to_add; i++)
								free(lines_to_add[i]);
							
							if (force_add_doc[0] != 0)
								description_ongoing = 0;
						}
					}
					
				} else if (discussion_ongoing && trimmed[0] != '*') {
					long num_lines = num_discussion_lines;
					
					if (num_lines >= MAX_DISCUSSION_LINES)
						discussion_ongoing = 0;
					else {
						trimmed = lefttrim(trimmed, num_lines == 0 ? false : true);
						if (!trimmed)
							discussion_ongoing = 0;
						else {
							char *lines_to_add[MAX_COMMON_REFERENCE_LINES];
							long num_lines_to_add = 0;
							
							if (force_add_doc[0] != 0 || strncmp(trimmed, "@copy", 5) == 0) {
								long offset = 5;
								char dont_copy = false;
								if (strncmp(trimmed, "@copyif ", 8) == 0) {
									char temp[MAX_SINGLE_ELEM_CHARS];
									long temp_len = strlen(obj_name);
									strncpy(temp, obj_name, MAX_SINGLE_ELEM_CHARS - 1);
									temp[temp_len] = ' ';
									temp[temp_len+1] = 0;
									if (strncmp(lefttrim(trimmed + 8, false), temp, temp_len+1) != 0) {
										dont_copy = true;
									}
									offset = 8 + temp_len;
								} 
								if (!dont_copy) {
									char name[MAX_SINGLE_ELEM_CHARS];
									strncpy(name, force_add_doc[0] != 0 ? force_add_doc : lefttrim(trimmed + offset, false), MAX_SINGLE_ELEM_CHARS - 1);
									righttrim(name, true);
									recursion_depth = 0;
									if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file1, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
										if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file2, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
                                            if (!obtain_common_reference(name, lines_to_add, &num_lines_to_add, common_ref_file3, common_ref_file1, common_ref_file2, common_ref_file3, error_log, true, true))
                                                [error_log setString:[NSString stringWithFormat: @"%@ • Reference %s could not be found.\n", [error_log string], name]];
									
									// Setting _NAME variable value
									long j;
									for (j = 0; j < num_lines_to_add; j++) {
										char *pos = strstr(lines_to_add[j], "_NAME");
										char foo;
										foo = 7;
										if (pos && 
											(pos == lines_to_add[j] || *(pos-1) == '>' || *(pos-1) == '/' || *(pos - 1) == ' ') && 
											(*(pos+5) == 0 || *(pos+5) == ' '|| *(pos+5) == '/' || *(pos+5) == '<')) {
											char *cpy = strdup(pos+5);
											
											snprintf(pos, MAX_DISCUSSION_LINES - (pos-lines_to_add[j]) - 1, "%s%s", obj_name, cpy);
											free(cpy);
										}
									}
									
								}
							} else {
								lines_to_add[0] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
								strncpy(lines_to_add[0], trimmed, MAX_LINE_CHARS - 1);
								num_lines_to_add = 1;
							}
							
							for (i = 0; i < num_lines_to_add && num_lines < MAX_DISCUSSION_LINES; i++, num_lines++) {
								strncpy(discussion[num_discussion_lines], lines_to_add[i], MAX_LINE_CHARS - 1);
								righttrim(discussion[num_discussion_lines], 0);
								num_discussion_lines++;
							}
							
							for (i = 0; i < num_lines_to_add; i++)
								free(lines_to_add[i]);
							
							if (force_add_doc[0] != 0)
								discussion_ongoing = 0;
						}
					}
					/*				} else if (discussion_ongoing && trimmed[0] != '*') {
					 if (num_discussion_lines >= MAX_DISCUSSION_LINES)
					 discussion_ongoing = 0;
					 else {
					 strncpy(discussion[num_discussion_lines], trimmed, MAX_LINE_CHARS - 1);
					 righttrim(discussion[num_discussion_lines], 0);
					 num_discussion_lines++;
					 }*/
				}
			}
		} else {
			description_ongoing = 0;
		}
	}	
	
	if (obj_name[0] == 0) {
		[error_log setString:[NSString stringWithFormat: @"%@ • Error: cannot find \"name\" tag.\n", [error_log string]]];
		fclose(fp_read);
		return;
	}
	
	if (obj_realname[0] == 0) {
		strncpy(obj_realname, obj_name, MAX_SINGLE_ELEM_CHARS-1);
		obj_realname[MAX_SINGLE_ELEM_CHARS-1] = 0;
		[error_log setString:[NSString stringWithFormat: @"%@ • Warning: \"realname\" tag not found, using \"name\".\n", [error_log string]]];
	}
	
	// num in and outs 1 based:
	num_out += 1;
	num_in += 1;
	
	righttrim(obj_name, 1);
	righttrim(digest, 0);
	righttrim(module, 0);
    righttrim(owner, 0);
	righttrim(author, 0);

	if (illustration_caption[0])
		righttrim(illustration_caption, 0);

	replace_char(illustration_caption, MAX_LINE_CHARS, '&', "&amp;");
	replace_char(digest, MAX_LINE_CHARS, '&', "&amp;");
	replace_char(author, MAX_SINGLE_ELEM_CHARS, '&', "&amp;");
	replace_char(module, MAX_SINGLE_ELEM_CHARS, '&', "&amp;");
    replace_char(owner, MAX_SINGLE_ELEM_CHARS, '&', "&amp;");

	for (i = 0; i < num_in; i++) {
		righttrim(in_digest[i], 0);
		replace_char(in_digest[i], MAX_LINE_CHARS, '&', "&amp;");
	}
	for (i = 0; i < num_out; i++) {
		righttrim(out_digest[i], 0);
		replace_char(out_digest[i], MAX_LINE_CHARS, '&', "&amp;");
	}
	for (i = 0; i < num_arg; i++) {
		righttrim(arg_digest[i], 0);
		replace_char(arg_digest[i], MAX_LINE_CHARS, '&', "&amp;");
	}
	for (i = 0; i < num_method; i++) {
		righttrim(method_digest[i], 0);
		replace_char(method_digest[i], MAX_LINE_CHARS, '&', "&amp;");
	}

    for (i = 0; i < num_method; i++) {
        for (j = 0; j < method_num_examples[i]; j++) {
            righttrim(method_example[i][j], 0);
            replace_standard(method_example[i][j], MAX_LINE_CHARS);
            
            righttrim(method_example_label[i][j], 0);
            replace_standard(method_example_label[i][j], MAX_LINE_CHARS);

            righttrim(method_seealso[i][j], 0);
            replace_standard(method_seealso[i][j], MAX_LINE_CHARS);
        }
    }
	
	
	for (i = 0; i < num_attr; i++) {
		substitute_slashed_quotes_in_string_with_escaped_quotes(attr_label[i], MAX_SINGLE_ELEM_CHARS);
		replace_char(attr_label[i], MAX_SINGLE_ELEM_CHARS, '&', "&amp;");
	}
	
	strcpy(fullfilename_write, output_folder);
	fullfilename_write[len_path_write] = '/';
	strcpy(fullfilename_write + len_path_write + 1, obj_realname);
	strcpy(fullfilename_write + len_path_write + 1 + strlen(obj_realname), ".maxref.xml");
	
    
    long this_idx = stats->num_modules;
    
    // FILLING STATS
    stats->module[this_idx].idx = this_idx;
    stats->module[this_idx].type = obj_type;
    stats->module[this_idx].status = status;
    strncpy(stats->module[this_idx].name, obj_name, MAX_SINGLE_ELEM_CHARS);
    strncpy(stats->module[this_idx].real_name, obj_realname, MAX_SINGLE_ELEM_CHARS);
    strncpy(stats->module[this_idx].digest, digest, MAX_LINE_CHARS);
    strncpy(stats->module[this_idx].c_source, filename, MAX_SINGLE_ELEM_CHARS);
    strncpy(stats->module[this_idx].owner, owner, MAX_SINGLE_ELEM_CHARS);

    stats->module[this_idx].num_categories = num_categories;
    for (i = 0; i < num_categories; i++)
        strncpy(stats->module[this_idx].category[i], category[i], MAX_SINGLE_ELEM_CHARS);

    stats->module[this_idx].num_seealso = num_see_also_elems;
    for (i = 0; i < num_see_also_elems; i++)
        strncpy(stats->module[this_idx].seealso[i], seealso[i], MAX_SINGLE_ELEM_CHARS);

    stats->module[this_idx].num_keywords = num_keyword_elems;
    for (i = 0; i < num_keyword_elems; i++)
        strncpy(stats->module[this_idx].keyword[i], keyword[i], MAX_SINGLE_ELEM_CHARS);
    

	if (status != k_STATUS_OK) {
        [error_log setString:[NSString stringWithFormat: @"%@ File %s.maxref.xml will not be written, because object is %s.\n",
							  [error_log string], obj_realname, (status == k_STATUS_DEPRECATED ? "deprecated" : (status == k_STATUS_EXPERIMENTAL ? "experimental" : "hidden"))]];
		
	} else {
		
		
		if (fp_c74contents) {
			char obj_realname_to_use[MAX_SINGLE_ELEM_CHARS];
			strncpy(obj_realname_to_use, obj_realname, MAX_SINGLE_ELEM_CHARS);
			replace_char(obj_realname_to_use, MAX_SINGLE_ELEM_CHARS, '&', "&amp;");
			fprintf(fp_c74contents,"<refpage name='%s.maxref.xml'/>\n", obj_realname_to_use);
		}
		
		if (fp_database) {
			if (strcmp(obj_name, obj_realname)) 
				fprintf(fp_database,"max db.addvirtual alias %s %s;\n", obj_name, obj_realname);
            if (obj_hiddenalias[0])
                fprintf(fp_database,"max db.addvirtual alias %s %s;\n", obj_hiddenalias, obj_realname);
		}
		
		if (fp_objectmappings) {
			if (strcmp(obj_name, obj_realname)) 
				fprintf(fp_objectmappings,"max objectfile %s %s;\n", obj_name, obj_realname);
            if (obj_hiddenalias[0])
                fprintf(fp_objectmappings,"max objectfile %s %s;\n", obj_hiddenalias, obj_realname);
		}
		
		if (fp_objectlist) {
			if (!separate_obj_and_abstr_in_objectlist || (obj_type != k_TYPE_OBJECT && obj_type != k_TYPE_ABSTRACTION))
				fprintf(fp_objectlist,"max oblist \"%s\" %s;\n", library_name, obj_name);
			else
				fprintf(fp_objectlist,"max oblist \"%s%s\" %s;\n", library_name, obj_type == k_TYPE_OBJECT ? " objects" : " abstractions", obj_name);
		}

        // check if the object is a math operator
        for (i = 0; i < num_categories; i++)
            if (strcmp(category[i], math_category) == 0) {
                obj_is_math_operator = true;
                break;
            }
        
        
		if (fp_object_qlookup) {
			long k;
			
			if (stats->num_objects[k_STATUS_OK] > 0 || stats->num_abstractions[k_STATUS_OK] > 0) // NOT the first element
				fprintf(fp_object_qlookup,",\n"); // we complete with a comma the previous unfinished line
			
			fprintf(fp_object_qlookup,"  \"%s\": {\n", obj_name);
			fprintf(fp_object_qlookup,"    \"digest\": \"%s\",\n", digest);
			fprintf(fp_object_qlookup,"    \"module\": \"%s\",\n", module);
			fprintf(fp_object_qlookup,"    \"category\": [\n");
			for (k = 0; k < num_categories; k++)
				fprintf(fp_object_qlookup,"      \"%s\"%s\n", category[k], k < num_categories - 1 ? "," : "");
			fprintf(fp_object_qlookup,"    ],\n");

            fprintf(fp_object_qlookup,"    \"keywords\": [\n");
            for (k = 0; k < num_keyword_elems; k++)
                fprintf(fp_object_qlookup,"      \"%s\"%s\n", keyword[k], k < num_keyword_elems - 1 ? "," : "");
            fprintf(fp_object_qlookup,"    ],\n");

            fprintf(fp_object_qlookup,"    \"seealso\": [\n");
            for (k = 0; k < num_see_also_elems; k++)
                fprintf(fp_object_qlookup,"      \"%s\"%s\n", seealso[k], k < num_see_also_elems - 1 ? "," : "");
            fprintf(fp_object_qlookup,"    ]%s\n", has_palette ? "," : "");

			if (has_palette) {
				fprintf(fp_object_qlookup,"    \"palette\": {\n");
				fprintf(fp_object_qlookup,"      \"category\": [\n");
				for (k = 0; k < num_categories; k++)
					fprintf(fp_object_qlookup,"        \"%s\"%s\n", category[k], k < num_categories - 1 ? "," : "");
				fprintf(fp_object_qlookup,"      ],\n"); 
				fprintf(fp_object_qlookup,"      \"action\": \"%s\",\n", obj_name);
				fprintf(fp_object_qlookup,"      \"pic\": \"%s.svg\"\n", obj_name);
				fprintf(fp_object_qlookup,"    }\n");
			}
            fprintf(fp_object_qlookup,"  }");
		}
		
		if (export_XMLs) {
			
			[error_log setString:[NSString stringWithFormat: @"%@ Writing file %s.maxref.xml...\n", [error_log string], obj_realname]];
			fp_write = fopen(fullfilename_write, "w");
			
			if (fp_write == NULL) {
				[error_log setString:[NSString stringWithFormat: @"%@ Failed to open %s for write.\n", [error_log string], fullfilename_write]];
				return;
			}
			
			fprintf(fp_write,"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>\n");
			fprintf(fp_write,"<?xml-stylesheet href=\"./_c74_ref.xsl\" type=\"text/xsl\"?>\n\n");
			
			
			fprintf(fp_write,"<!--This file has been automatically generated by Doctor Max. DO NOT EDIT THIS FILE DIRECTLY.-->\n\n");
			
			char obj_name_to_use[MAX_SINGLE_ELEM_CHARS];
			strncpy(obj_name_to_use, obj_name, MAX_SINGLE_ELEM_CHARS);
			
			replace_char(obj_name_to_use, MAX_SINGLE_ELEM_CHARS, '&', "&amp;");
			replace_char(obj_name_to_use, MAX_SINGLE_ELEM_CHARS, '<', "&lt;");
			replace_char(obj_name_to_use, MAX_SINGLE_ELEM_CHARS, '>', "&gt;");
			
            fprintf(fp_write,"<c74object name=\"%s\" module=\"%s\"%s%s>\n\n", obj_name_to_use, module, obj_type == k_TYPE_ABSTRACTION ?  " kind=\"patcher\"" : "", obj_is_math_operator ? " category=\"Math\"" : "");

/*            if (obj_type == k_TYPE_ABSTRACTION)
				fprintf(fp_write,"<c74object name=\"%s\" module=\"%s\" kind=\"patcher\">\n\n", obj_name_to_use, module);
			else
				fprintf(fp_write,"<c74object name=\"%s\" module=\"%s\">\n\n", obj_name_to_use, module);
*/
            
//			why did I also have this???
//			fprintf(fp_write,"<c74object name=\"%s\" module=\"%s\" category=\"%s\">\n\n", obj_name_to_use, module, category);
			
			fprintf(fp_write,"\t<digest>\n");
			fprintf(fp_write,"\t\t%s\n", digest);
			fprintf(fp_write,"\t</digest>\n\n");
			
			fprintf(fp_write,"\t<description>\n");
			for (i = 0; i < num_description_lines; i++)
				fprintf(fp_write,"\t\t%s\n", description[i]);
			fprintf(fp_write,"\t</description>\n\n");
			
			
			fprintf(fp_write,"\t<!--METADATA-->\n");
			fprintf(fp_write,"\t<metadatalist>\n");
			fprintf(fp_write,"\t\t<metadata name=\"author\">%s</metadata>\n", author);
			for (i = 0; i < num_categories; i++)
				fprintf(fp_write,"\t\t<metadata name=\"tag\">%s</metadata>\n", category[i]);
			fprintf(fp_write,"\t</metadatalist>\n\n");
			
			if (num_in > 0) {
				fprintf(fp_write,"\t<!--INLETS-->\n");
				fprintf(fp_write,"\t<inletlist>\n");
				for (i = 0; i < num_in; i++) {
					fprintf(fp_write,"\t\t<inlet id=\"%ld\" type=\"INLET_TYPE\">\n", i);
					fprintf(fp_write,"\t\t\t<digest>\n");
					fprintf(fp_write,"\t\t\t\t%s\n", in_digest[i]);
					fprintf(fp_write,"\t\t\t</digest>\n");
					fprintf(fp_write,"\t\t\t<description>\n");
					for (j = 0; j < num_in_description_lines[i]; j++)
						fprintf(fp_write,"\t\t\t\t%s\n", in_description[i][j]);
					fprintf(fp_write,"\t\t\t</description>\n");
					fprintf(fp_write,"\t\t</inlet>\n");
				}
				fprintf(fp_write,"\t</inletlist>\n\n");
			}
			
			if (num_out > 0) {
				fprintf(fp_write,"\t<!--OUTLETS-->\n");
				fprintf(fp_write,"\t<outletlist>\n");
				for (i = 0; i < num_out; i++) {
					fprintf(fp_write,"\t\t<outlet id=\"%ld\" type=\"INLET_TYPE\">\n", i);
					fprintf(fp_write,"\t\t\t<digest>\n");
					fprintf(fp_write,"\t\t\t\t%s\n", out_digest[i]);
					fprintf(fp_write,"\t\t\t</digest>\n");
					fprintf(fp_write,"\t\t\t<description>\n");
					for (j = 0; j < num_out_description_lines[i]; j++)
						fprintf(fp_write,"\t\t\t\t%s\n", out_description[i][j]);
					fprintf(fp_write,"\t\t\t</description>\n");
					fprintf(fp_write,"\t\t</outlet>\n");
				}
				fprintf(fp_write,"\t</outletlist>\n\n");
			}
			
			fprintf(fp_write,"\t<!--ARGUMENTS-->\n");
			fprintf(fp_write,"\t<objarglist>\n");
			for (i = 0; i < num_arg; i++) {
				if (!arg_name[i][0])
					continue;
				fprintf(fp_write,"\t\t<objarg name=\"%s\" optional=\"%d\" type=\"%s\">\n", arg_name[i], arg_optional[i], arg_type[i]);
				fprintf(fp_write,"\t\t\t<digest>\n");
				fprintf(fp_write,"\t\t\t\t%s\n", arg_digest[i]);
				fprintf(fp_write,"\t\t\t</digest>\n");
				fprintf(fp_write,"\t\t\t<description>\n");
				for (j = 0; j < num_arg_description_lines[i]; j++)
					fprintf(fp_write,"\t\t\t\t%s\n", arg_description[i][j]);
				fprintf(fp_write,"\t\t\t</description>\n");
				fprintf(fp_write,"\t\t</objarg>\n");
			}
			fprintf(fp_write,"\t</objarglist>\n\n");
			
			
			long k;
			
			t_indexed_name indexedmess[MAX_METHODS];
			for (i = 0; i < num_method; i++) {
				strncpy(indexedmess[i].name, method_name[i], MAX_SINGLE_ELEM_CHARS);
				indexedmess[i].idx = i;
			}
			if (sort_methods)
				qsort(indexedmess, num_method, sizeof(t_indexed_name), indexed_name_cmp);
			
			fprintf(fp_write,"\t<!--MESSAGES-->\n");
			fprintf(fp_write,"\t<methodlist>\n");
			for (k = 0; k < num_method; k++) {
				i = indexedmess[k].idx;
				fprintf(fp_write,"\t\t<method name=\"%s\">\n", method_name[i]);
				if (method_num_args[i] == 0)
					fprintf(fp_write,"\t\t\t<arglist />\n");
				else {
					for (j = 0; j < method_num_args[i]; j++)
						fprintf(fp_write,"\t\t\t<arg name=\"%s\" optional=\"%d\" type=\"%s\" />\n", method_arg_name[i][j], method_arg_optional[i][j], method_arg_type[i][j]);
				}
				fprintf(fp_write,"\t\t\t<digest>\n");
				fprintf(fp_write,"\t\t\t\t%s\n", method_digest[i]);
				fprintf(fp_write,"\t\t\t</digest>\n");
				fprintf(fp_write,"\t\t\t<description>\n");
                
                if ((add_syntax_before_method_description > 0 && method_num_args[i] > 0) ||
                    (add_syntax_before_method_description > 1)) {
                    // building syntax
                    fprintf(fp_write,"\t\t\t\tSyntax: <b>%s", method_name[i]);
                    long h;
                    for (h = 0; h < method_num_args[i]; h++) {
                        if (method_arg_optional[i][h])
                            fprintf(fp_write, " <m>[&lt;%s: %s&gt;]</m>", method_arg_type[i][h], method_arg_name[i][h]);
                        else
                            fprintf(fp_write, " <m>&lt;%s: %s&gt;</m>", method_arg_type[i][h], method_arg_name[i][h]);
                    }
                    if (method_num_attrs[i] > 0)
                        fprintf(fp_write, " <i>[message attributes]</i>");
                    fprintf(fp_write, " </b><br />");
                    if (method_num_examples[i] == 0)
                        fprintf(fp_write, "\t\t\t\t<br />\n");
                    else
                        fprintf(fp_write, "\n");
                }
                
                if (method_num_examples[i] > 0) {
                    long h;
                    if (method_num_examples[i] > 1) {
                        fprintf(fp_write, "\t\t\t\tExamples:<br />\n");
                        for (h = 0; h < method_num_examples[i]; h++) {
                            if (method_example_label[i][h][0])
                                fprintf(fp_write, "\t\t\t\t• <b>%s</b>   <i>→ %s</i><br />\n", method_example[i][h], method_example_label[i][h]);
                            else
                                fprintf(fp_write, "\t\t\t\t• <b>%s</b><br />\n", method_example[i][h]);
                        }
                    } else {
                        for (h = 0; h < method_num_examples[i]; h++) { // should be just 1, we keep the full cycle in case we wanna switch back to this default behavior
                            if (method_example_label[i][h][0])
                                fprintf(fp_write, "\t\t\t\tExample: <b>%s</b>   <i>→ %s</i><br />\n", method_example[i][h], method_example_label[i][h]);
                            else
                                fprintf(fp_write, "\t\t\t\tExample: <b>%s</b><br />\n", method_example[i][h]);
                        }
                    }
                    fprintf(fp_write, "\t\t\t\t<br />\n");
                }
                
                if (method_num_attrs[i] > 0) {
                    long h;
                    fprintf(fp_write, "\t\t\t\tMessage attributes:<br />\n");
                    for (h = 0; h < method_num_attrs[i]; h++) {
                        if (method_attr_default[i][h][0])
                            fprintf(fp_write, "\t\t\t\t<m>@%s</m> (%s, default: %s): %s<br />\n", method_attr_name[i][h], method_attr_type[i][h], method_attr_default[i][h], method_attr_digest[i][h]);
                        else
                            fprintf(fp_write, "\t\t\t\t<m>@%s</m> (%s): %s<br />\n", method_attr_name[i][h], method_attr_type[i][h], method_attr_digest[i][h]);
                    }
                    fprintf(fp_write, "\t\t\t\t<br />\n");
                }
                
                for (j = 0; j < num_method_description_lines[i]; j++) {
					fprintf(fp_write,"\t\t\t\t%s\n", method_description[i][j]);
                }
                if (method_num_seealso[i] > 0){
                    long h;
                    fprintf(fp_write, "\t\t\t\t<br />");
                    fprintf(fp_write, "\t\t\t\tSee also:");
                    for (h = 0; h < method_num_seealso[i]; h++)
                        fprintf(fp_write, "<m>%s</m>%s", method_seealso[i][h], h == method_num_seealso[i] - 1 ? "" : ",");
                    fprintf(fp_write, "<br />\n");
                }
				fprintf(fp_write,"\t\t\t</description>\n");
				fprintf(fp_write,"\t\t</method>\n");
			}
			fprintf(fp_write,"\t</methodlist>\n\n");
			
			
			// sorting attributes alphabetically
			t_indexed_name indexedattrs[MAX_ATTRIBUTES];
			for (i = 0; i < num_attr; i++) {
				strncpy(indexedattrs[i].name, attr_name[i], MAX_SINGLE_ELEM_CHARS);
				indexedattrs[i].idx = i;
			}
			if (sort_attributes)
				qsort(indexedattrs, num_attr, sizeof(t_indexed_name), indexed_name_cmp);
			
			
			fprintf(fp_write,"\t<!--ATTRIBUTES-->\n");
			fprintf(fp_write,"\t<attributelist>\n");
			for (k = 0; k < num_attr; k++) {
				i = indexedattrs[k].idx;
				if (attr_undocumented[i] || attr_name[i][0] == 0)
					continue;
				fprintf(fp_write,"\t\t<attribute name=\"%s\" get=\"1\" set=\"1\" type=\"%s\" size=\"%ld\">\n", attr_name[i], attr_type[i], attr_size[i]);
				fprintf(fp_write,"\t\t\t<digest>\n");
				fprintf(fp_write,"\t\t\t\t%s\n", attr_label[i]);
				fprintf(fp_write,"\t\t\t</digest>\n");
				fprintf(fp_write,"\t\t\t<description>\n");
				for (j = 0; j < num_attr_description_lines[i]; j++)
					fprintf(fp_write,"\t\t\t\t%s\n", attr_description[i][j]);
				fprintf(fp_write,"\t\t\t</description>\n");
				
				fprintf(fp_write,"\t\t\t<attributelist>\n"); // attributes of the attribute!!
				if (attr_category[i][0])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"category\" get=\"1\" set=\"1\" type=\"symbol\" size=\"1\" value=\"%s\" />\n", attr_category[i]);
				if (attr_default[i][0])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"default\" get=\"1\" set=\"1\" type=\"%s\" size=\"%ld\" value=\"%s\" />\n", attr_type[i], attr_size[i], attr_default[i]);
				if (attr_label[i][0])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"label\" get=\"1\" set=\"1\" type=\"symbol\" size=\"1\" value=\"%s\" />\n", attr_label[i]);
				if (attr_paint[i])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"paint\" get=\"1\" set=\"1\" type=\"int\" size=\"1\" value=\"1\" />\n");
				if (attr_save[i])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"save\" get=\"1\" set=\"1\" type=\"int\" size=\"1\" value=\"1\" />\n");
				if (attr_style[i][0])
					fprintf(fp_write,"\t\t\t\t<attribute name=\"style\" get=\"1\" set=\"1\" type=\"symbol\" size=\"1\" value=\"%s\" />\n", attr_style[i]);
				fprintf(fp_write,"\t\t\t</attributelist>\n");
				
				fprintf(fp_write,"\t\t</attribute>\n");
			}
			fprintf(fp_write,"\t</attributelist>\n\n");
			
			if (has_illustration) {
				fprintf(fp_write,"\t<!--EXAMPLE-->\n");
				fprintf(fp_write,"\t<examplelist>\n");
				if (illustration_caption[0] == 0)
					fprintf(fp_write,"\t\t<example img=\"%s.png\">\n", obj_name);
				else
					fprintf(fp_write,"\t\t<example img=\"%s.png\" caption=\"%s\" />\n", obj_name, illustration_caption);
				fprintf(fp_write,"\t</examplelist>\n\n");
			}
			
			//
			//	while ( fgets(line, sizeof line, fp_read) != NULL ) /* read a line */
			//	{
			//		fputs ( line, stdout ); /* write the line */
			//	}
			//	
			
			if (num_discussion_lines > 0) {
				fprintf(fp_write,"\t<!--DISCUSSION-->\n");
				fprintf(fp_write,"\t<discussion>\n");
				for (i = 0; i < num_discussion_lines; i++)
					fprintf(fp_write,"\t\t%s\n", discussion[i]);
				fprintf(fp_write,"\t</discussion>\n\n");
			}
			
			fprintf(fp_write,"\t<!--SEEALSO-->\n");
			fprintf(fp_write,"\t<seealsolist>\n");
			for (i = 0; i < num_see_also_elems; i++) {
				if (seealso[i][0] >= 'A' && seealso[i][0] <= 'Z') {
					// If it starts with capital letter, we consider it to be a tutorial. We need to match it to its proper numbering, on the other hand...
					
					/// FIND TUTORIAL INDEX
					char tutorial_file_name[MAX_SINGLE_ELEM_CHARS];
					if (for_bach)
						tutorial_name_to_filename(seealso[i], BACH_TUTORIAL_FOLDER, tutorial_file_name);
					else
						strncpy(tutorial_file_name, seealso[i], MAX_SINGLE_ELEM_CHARS);
					
					fprintf(fp_write,"\t\t<seealso name=\"%s\" module=\"%s\" type=\"tutorial\" />\n", tutorial_file_name, module);
                } else {
                    // gotta detect whether seealso[i] is an alias for something else.
                    long alias_idx = -1;
                    for (long a = 0; a < num_aliases; a++)
                        if (strcmp(harvested_alias[a], seealso[i]) == 0) {
                            alias_idx = a;
                            break;
                        }
                    if (alias_idx > 0)
                        fprintf(fp_write,"\t\t<seealso name=\"%s\" display=\"%s\" type=\"refpage\" />\n", harvested_realname[alias_idx], seealso[i]);
                    else
                        fprintf(fp_write,"\t\t<seealso name=\"%s\" />\n", seealso[i]);
                }
			}
			fprintf(fp_write,"\t</seealsolist>\n\n");
			
			
			if (export_in_out_as_misc) {
				
				if (num_in > 0) {
					fprintf(fp_write,"\t<misc name = \"Input\">\n");
					long in_loop_size = 0, num_ins_after_loop = 0;
					for (i = 0; i < num_in; i++) {
						if (in_loop[i]) {
							if (in_loop[i] > in_loop_size)
								in_loop_size = in_loop[i];
							num_ins_after_loop = num_in - i - 1;
						}
					}
					char after_in_loop = false;
					for (i = 0; i < num_in; i++) {
						char type_string[MAX_SINGLE_ELEM_CHARS + 3];
						type_string[0] = 0;
						if (in_type[i][0])
							sprintf(type_string, " (%s)", in_type[i]);
						if (in_loop[i]) {
							after_in_loop = true;
							fprintf(fp_write,"\t\t<entry name =\"Inlets %ld, %ld, %ld...%s\">\n", i + 1, i + 1 + in_loop_size, i + 1 + 2 * in_loop_size, type_string);
						} else {
							if (after_in_loop) {
								if (num_in - i - 1 == 0)
									fprintf(fp_write,"\t\t<entry name =\"The last Inlet%s\">\n", type_string);
								else
									fprintf(fp_write,"\t\t<entry name =\"The last but %ld Inlet%s\">\n", num_in - i - 1, type_string);
							} else {
								fprintf(fp_write,"\t\t<entry name =\"Inlet %ld%s\">\n", i + 1, type_string);
							}
						}
						fprintf(fp_write,"\t\t\t<description>\n");
						fprintf(fp_write,"\t\t\t\t%s.\n", in_digest[i]);
						for (j = 0; j < num_in_description_lines[i]; j++)
							fprintf(fp_write,"\t\t\t\t%s\n", in_description[i][j]);
						fprintf(fp_write,"\t\t\t</description>\n");
						fprintf(fp_write,"\t\t</entry>\n");
					}
					fprintf(fp_write,"\t</misc>\n\n");
				}
				
				if (num_out > 0){
					long out_loop_size = 0, num_outs_after_loop = 0;
					for (i = 0; i < num_out; i++) {
						if (out_loop[i]) {
							if (out_loop[i] > out_loop_size)
								out_loop_size = out_loop[i];
							num_outs_after_loop = num_out - i - 1;
						}
					}
					char after_out_loop = false;
					fprintf(fp_write,"\t<misc name = \"Output\">\n");
					for (i = 0; i < num_out; i++) {
						char type_string[MAX_SINGLE_ELEM_CHARS + 3];
						type_string[0] = 0;
						if (out_type[i][0])
							sprintf(type_string, " (%s)", out_type[i]);
						if (out_loop[i]) {
							after_out_loop = true;
							fprintf(fp_write,"\t\t<entry name =\"Outlets %ld, %ld, %ld...%s\">\n", i + 1, i + 1 + out_loop_size, i + 1 + 2 * out_loop_size, type_string);
						} else {
							if (after_out_loop) {
								if (num_out - i - 1 == 0)
									fprintf(fp_write,"\t\t<entry name =\"The last Outlet%s\">\n", type_string);
								else
									fprintf(fp_write,"\t\t<entry name =\"The last but %ld Outlet (%s)\">\n", num_out - i - 1, out_type[i]);
							} else {
								fprintf(fp_write,"\t\t<entry name =\"Outlet %ld%s\">\n", i + 1, type_string);
							}
						}
						fprintf(fp_write,"\t\t\t<description>\n");
						fprintf(fp_write,"\t\t\t\t%s.\n", out_digest[i]);
						for (j = 0; j < num_out_description_lines[i]; j++)
							fprintf(fp_write,"\t\t\t\t%s\n", out_description[i][j]);
						fprintf(fp_write,"\t\t\t</description>\n");
						fprintf(fp_write,"\t\t</entry>\n");
					}
					fprintf(fp_write,"\t</misc>\n\n");
				}
			}
			
			
			if (export_discussion_as_misc && num_discussion_lines > 0) {
				fprintf(fp_write,"\t<misc name = \"Discussion\">\n");
				fprintf(fp_write,"\t\t<entry name =\"More details\">\n");
				fprintf(fp_write,"\t\t\t<description>\n");
				for (i = 0; i < num_discussion_lines; i++)
					fprintf(fp_write,"\t\t%s\n", discussion[i]);
				fprintf(fp_write,"\t\t\t</description>\n");
				fprintf(fp_write,"\t\t</entry>\n");
				fprintf(fp_write,"\t\t<entry name =\"Keywords\">\n");
				fprintf(fp_write,"\t\t\t<description>\n");
				if (num_keyword_elems > 0) {
					for (i = 0; i < num_keyword_elems; i++)
						fprintf(fp_write, i == num_keyword_elems - 1 ? "%s.\n" : "%s, ", keyword[i]);
				}
				fprintf(fp_write,"\t\t\t</description>\n");
				fprintf(fp_write,"\t\t</entry>\n");
				fprintf(fp_write,"\t</misc>\n\n");
			}
			
			
			fprintf(fp_write,"</c74object>");
			fclose(fp_write);
		}
	}
    
    // LAST STATS (need them here, later)
    if (obj_type == k_TYPE_OBJECT)
        stats->num_objects[status] ++;
    else if (obj_type == k_TYPE_ABSTRACTION)
        stats->num_abstractions[status] ++;
    stats->num_modules ++; // incrementing count of written elements

    
    
	for (i = 0; i < MAX_DESCRIPTION_LINES; i++)
		free(description[i]);
	for (i = 0; i < MAX_DISCUSSION_LINES; i++)
		free(discussion[i]);
	for (i = 0; i < MAX_METHODS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			free(method_description[i][j]);
    for (i = 0; i < MAX_METHODS; i++) {
        for (j = 0; j < MAX_METHOD_EXAMPLES; j++) {
            free(method_example[i][j]);
            free(method_example_label[i][j]);
        }
        for (j = 0; j < MAX_METHOD_SEEALSO_ELEMS; j++)
            free(method_seealso[i][j]);
    }
    for (i = 0; i < MAX_ATTRIBUTES; i++) {
		free(attr_category[i]);
		free(attr_label[i]);
		free(attr_style[i]);
		free(attr_default[i]);
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			free(attr_description[i][j]);
	}
	for (i = 0; i < MAX_INLETS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			free(in_description[i][j]);
	for (i = 0; i < MAX_OUTLETS; i++)
		for (j = 0; j < MAX_DESCRIPTION_LINES; j++)
			free(out_description[i][j]);
	
	
	
	for (i = 0; i < 100; i++)
		free(seealso[i]);
	
	for (i = 0; i < 20; i++)
		free(category[i]);
	
	fclose(fp_read);
}

// return starting point, non destructive
char *lefttrim(char *str, char also_trim_slashes)
{
	long i, len = strlen(str);
	
	for(i = 0; i < len; i++){
		if (str[i] != ' ' && str[i] != '\t' && str[i] != '\n' && (!also_trim_slashes || str[i] != '/')) 
			return &str[i];
	} 
	return NULL;
} 

// changes ending point, destructive
void righttrim(char *str, char stop_at_first_space)
{
	long i, len = strlen(str);
	
	for(i = stop_at_first_space ? 0 : len - 1; stop_at_first_space ? i < len : i >= 0; stop_at_first_space ? i++ : i--){
		if (str[i] == ' ' || str[i] == '\t' || str[i] == '\n') {
			str[i] = 0;
			if (stop_at_first_space)
				return;
		} else {
			if (!stop_at_first_space)
				return;
		}
	}
}

void righttrim_with_at(char *str)
{
    long i, len = strlen(str);
    
    for (i = 0; i < len; i++){
        if (str[i] == '@' || str[i] == '\t' || str[i] == '\n') {
            str[i] = 0;
            return;
        }
    }
}


void split_string(const char *str, char *token, char **array, long max_num_splitted_elems, long *num_elems)
{
	char *pch;
	long i = 0;
	long str_len = strlen(str);
	char *str_copy = (char *)malloc((str_len+1)*sizeof(char));
	
	strcpy(str_copy, str);
	
	pch = strtok(str_copy, token); // " ,.-"
	
	while (pch != NULL && i < max_num_splitted_elems)
	{
		char *tr = lefttrim(pch, false);
		if (tr && strlen(tr) > 0) {
			strncpy(array[i], tr, MAX_SINGLE_ELEM_CHARS - 1);
			//		printf ("%s\n",pch);
			i++;
		}
		pch = strtok (NULL, token);
	}
	*num_elems = i;
	
	for (i = 0; i < *num_elems; i++)
		righttrim(array[i], 0);
	
	free(str_copy);
}


// obtain common reference lines, situated in "#define"s of the file bach_doc_commons.c
// returns 1 if found
char obtain_common_reference(char *ref_tag, char **lines_to_add, long *num_lines_to_add, char *reference_path,
							 char *common_ref_file1, char *common_ref_file2, char *common_ref_file3, NSTextView *error_log, char no_spaces_tag, char only_copy_slashed_lines)
{
	
	FILE *fp_common_read;
	char found = false;
	long i = 0;
	char line[MAX_LINE_CHARS];
	
	if (!reference_path || strlen(reference_path) == 0) 
		return 0; // no file
	
	fp_common_read = fopen(reference_path, "r");
	
	if (fp_common_read == NULL) {
		[error_log setString:[NSString stringWithFormat: @"%@ • Failed to open reference file %s for read.\n", [error_log string], reference_path]];
		return 0;
    }
	
	while (fgets(line, sizeof line, fp_common_read) != NULL) /* read a line */
	{
		char *trimmed = lefttrim(line, false);
		if (trimmed) {
			if (strncmp(trimmed, "#define", 7) == 0) {
				char temp[MAX_LINE_CHARS];
				trimmed = lefttrim(trimmed + 7, false);
				strncpy(temp, trimmed, MAX_LINE_CHARS - 1);
				righttrim(temp, no_spaces_tag);
				if (strcmp(temp, ref_tag) == 0) {
					char *trim2;
					found = true;
					i = 0;
					while (i < MAX_COMMON_REFERENCE_LINES && fgets(line, sizeof line, fp_common_read) != NULL)
					{
						long num_sublines = 0;
						char *sublines_to_add[MAX_COMMON_REFERENCE_LINES];
						
						trim2 = lefttrim(line, false);
						
						if (!trim2 || strlen(trim2) == 0 || (only_copy_slashed_lines && trim2[0] != '/'))
							break;
						
						trim2 = lefttrim(trim2, only_copy_slashed_lines);
						
						if (trim2 && recursion_depth < MAX_RECURSION_DEPTH_FOR_COPYING && strncmp(trim2, "@copy", 5) == 0) {
							// there was a @copy inside a @copy, recursive!
							char name[MAX_SINGLE_ELEM_CHARS];
							strncpy(name, lefttrim(trim2 + 5, false), MAX_SINGLE_ELEM_CHARS - 1);
							righttrim(name, no_spaces_tag);
							
							recursion_depth++;
							if (!obtain_common_reference(name, sublines_to_add, &num_sublines, common_ref_file1, common_ref_file1, common_ref_file2, common_ref_file3, error_log, no_spaces_tag, only_copy_slashed_lines))
								if (!obtain_common_reference(name, sublines_to_add, &num_sublines, common_ref_file2, common_ref_file1, common_ref_file2, common_ref_file3, error_log, no_spaces_tag, only_copy_slashed_lines))
                                    if (!obtain_common_reference(name, sublines_to_add, &num_sublines, common_ref_file3, common_ref_file1, common_ref_file2, common_ref_file3, error_log, no_spaces_tag, only_copy_slashed_lines))
                                        [error_log setString:[NSString stringWithFormat: @"%@ • Reference %s could not be found.\n", [error_log string], name]];
						} else if (trim2) {
							num_sublines = 1;
							sublines_to_add[0] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
							strncpy(sublines_to_add[0], trim2, MAX_LINE_CHARS - 1);
						}
						
						long k;
						long cc = 0;
						for (k = 0; k < num_sublines && i + k < MAX_COMMON_REFERENCE_LINES; k++) {
							lines_to_add[i + k] = (char *)malloc(MAX_LINE_CHARS * sizeof(char));
							strncpy(lines_to_add[i + k], sublines_to_add[k], MAX_LINE_CHARS - 1);
							cc++;
						}
						
						for (k = 0; k < num_sublines; k++)
							free(sublines_to_add[k]);
						
						i += cc;
						//						i += num_sublines;
					}
					break;
				}
			}
		}
	}
	
	*num_lines_to_add = i;
	
	fclose(fp_common_read);
	return found;
}


void replace_char(char *string, long allocated_size, char char_to_replace, char *replacement_string)
{
	long i, j;
    long string_size = strlen(string);
	long replacement_string_len = strlen(replacement_string);
	for (i = 0; i < string_size; ) {
		if (string[i] == char_to_replace) {
			if (replacement_string_len == 0) {
				string_size--;
				for (j = i+1; j < string_size; j++)
					string[j-1] = string[j];
                string[MIN(string_size-1, allocated_size-1)] = 0;
			} else {
                for (j = string_size - 1; j >= i+1; j--) {
                    if (j+replacement_string_len - 1 < allocated_size)
                        string[j+replacement_string_len - 1] = string[j];
                }
				for (j = 0; j < replacement_string_len && i + j < allocated_size; j++)
					string[i+j] = replacement_string[j];
                string[MIN(string_size + replacement_string_len, allocated_size - 1)] = 0;
				i+=replacement_string_len;
                string_size+=replacement_string_len - 1;
			}
		} else
			i++;
	}
}



void replace_substring(char *string, long allocated_size, char *substring_to_replace, char *replacement_string)
{
    long i, j;
    long string_size = strlen(string);
    long substring_size = strlen(substring_to_replace);
    long replacement_string_len = strlen(replacement_string);
    for (i = 0; i < string_size - substring_size + 1; ) {
        if (!strncmp(substring_to_replace, string + i, substring_size)) {
            if (replacement_string_len == 0) {
                string_size-=substring_size;
                for (j = i+substring_size; j < string_size; j++)
                    string[j-substring_size] = string[j];
                string[MIN(string_size-substring_size, allocated_size-1)] = 0;
            } else {
                for (j = string_size - 1; j >= i+substring_size; j--) {
                    if (j+replacement_string_len - substring_size < allocated_size)
                        string[j+replacement_string_len - substring_size] = string[j];
                }
                for (j = 0; j < replacement_string_len && i + j < allocated_size; j++)
                    string[i+j] = replacement_string[j];
                string[MIN(string_size + replacement_string_len, allocated_size - 1)] = 0;
                i+=replacement_string_len;
                string_size+=replacement_string_len - substring_size;
            }
        } else
            i++;
    }
}


char *get_next_double_quotes(char *string, char exclude_backslashed)
{
	char *temp = strstr(string, "\"");
	
	if (exclude_backslashed) {
		while (temp && temp != string && *(temp-1) == '\\') {
			temp = strstr(temp + 1, "\"");
		}
	} 
	
	return temp;
}


void substitute_slashed_quotes_in_string_with_escaped_quotes(char *string, long max_string_length)
{
	// We substitute \" with &quot; throughout all the string
	
	char *temp = strstr(string, "\\\"");
	long len = strlen(string);
	
	while (temp && len + 5 < max_string_length) {
		long size = strlen(temp) + 1;
		char *copy = strdup(temp+2);
		strncpy(temp + 6, copy, size);
		free(copy);
		
		*temp = '&';
		*(temp + 1) = 'q';
		*(temp + 2) = 'u';
		*(temp + 3) = 'o';
		*(temp + 4) = 't';
		*(temp + 5) = ';';
		
		temp = strstr(temp + 2, "\\\"");
	} 
}



////////////////////////////////////////////////////
// HELP CENTER HANDLING
////////////////////////////////////////////////////


void change_section_name(char *name)
{
    char newname[MAX_SINGLE_ELEM_CHARS];
    char *cur = name;
    
    while (*cur && ((*cur >= '0' && *cur <= '9') || *cur == '_'))
        cur++;

    strncpy(newname, cur, MAX_SINGLE_ELEM_CHARS - 1);
    
#ifdef BACH_REF
    if (strlen(newname) > 1 && strncmp(newname, "bach", 4))
        newname[0] = toupper(newname[0]);
    if (strcmp(newname, "Llll") == 0)
        snprintf(newname, MAX_SINGLE_ELEM_CHARS-1, "Lisp-like linked lists");
    if (strcmp(newname, "Bell") == 0)
        snprintf(newname, MAX_SINGLE_ELEM_CHARS-1, "Evaluation language (bell)");
#else
    if (strlen(newname) > 1)
        newname[0] = toupper(newname[0]);
#endif
    
    strncpy(name, newname, MAX_SINGLE_ELEM_CHARS-1);
}


void process_help_file(char *filename, char *source_path, char *help_router, FILE *output_file, NSTextField *progress_label, NSTextView *error_log, t_doctor_max_help_stats *stats)
{
    FILE *fp_read;
    char fullfilename_read[512];
    long len_path_read = strlen(source_path);
    char line[MAX_LINE_CHARS];

    strcpy(fullfilename_read, source_path);
    fullfilename_read[len_path_read] = '/';
    strcpy(fullfilename_read + len_path_read + 1, filename);
    
    // output in log and progress label
    char progress_label_str[FILENAME_MAX + 30];
    sprintf(progress_label_str, "Processing Help %s...", filename);
    [progress_label setStringValue:[NSString stringWithCString:progress_label_str encoding:NSASCIIStringEncoding]];
    [error_log setString:[NSString stringWithFormat: @"%@ Processing help file %s...\n", [error_log string], filename]];
    
    if (strlen(filename) <= strlen(help_router)) {
        [error_log setString:[NSString stringWithFormat: @"%@ Filename %s coincides with router. File is dropped.\n", [error_log string], filename]];
        return;
    }

        
    fp_read = fopen(fullfilename_read, "r");
    if (fp_read == NULL) {
        [error_log setString:[NSString stringWithFormat: @"%@ Failed to open file %s for read.\n", [error_log string], filename]];
        return;
    }
    
    long num_sections = 0;
    char *section[MAX_HELP_FILE_PATH_DEPTH];
    char title[MAX_SINGLE_ELEM_CHARS];
    long num_objects = 0;
    char *object[MAX_HELP_FILE_NUM_OBJS];
    long num_keywords = 0;
    char *keyword[MAX_KEYWORDS];
    long num_seealso = 0;
    char *seealso[MAX_SEEALSO_ELEMS];
    
    title[0] = 0;
    
    long i;
    for (i = 0; i < MAX_HELP_FILE_PATH_DEPTH; i++)
        section[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
    for (i = 0; i < MAX_HELP_FILE_NUM_OBJS; i++)
        object[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
    for (i = 0; i < MAX_KEYWORDS; i++)
        keyword[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));
    for (i = 0; i < MAX_SEEALSO_ELEMS; i++)
        seealso[i] = (char *)malloc(MAX_SINGLE_ELEM_CHARS * sizeof(char));

    
    char last_text[MAX_LINE_CHARS];
    last_text[0] = 0;
    
    
    
    /// FILLING SECTIONS
    char *cur = filename + strlen(help_router) + 1;
    char copycur[MAX_LINE_CHARS];
    strncpy(copycur, cur, MAX_LINE_CHARS - 1);
    long len = strlen(copycur);
    if (len > 7) {
        for (i = len-7; i < len; i++)
            copycur[i] = 0; // remove the ".maxpat" extension.
    }
    split_string(copycur, ".", section, MAX_HELP_FILE_PATH_DEPTH, &num_sections);

    
    
    /// FILLING DATA
    
    while (true) /* read a line */
    {
        if (fgets(line, sizeof line, fp_read) == NULL)
            break;
        
        char *trimmed = lefttrim(line, false);
        
        if (trimmed) {
            if (strncmp(trimmed, "\"text\" : ", 9) == 0) {
                strncpy(last_text, trimmed + 10, MAX_LINE_CHARS - 1);
                righttrim(last_text, false);
                long len = strlen(last_text);
                if (len > 2) {
                    if (last_text[len-1] == ',')
                        last_text[len-1] = 0;
                    if (last_text[len-2] == '"')
                        last_text[len-2] = 0;
                }
            } else if (strncmp(trimmed, "\"varname\" : \"objects\"", 21) == 0) {
                split_string(last_text + 9, ",", object, MAX_HELP_FILE_NUM_OBJS, &num_objects);
            } else if (strncmp(trimmed, "\"varname\" : \"seealso\"", 21) == 0) {
                split_string(last_text + 9, ",", seealso, MAX_SEEALSO_ELEMS, &num_seealso);
            } else if (strncmp(trimmed, "\"varname\" : \"tags\"", 18) == 0) {
                split_string(last_text + 6, ",", keyword, MAX_KEYWORDS, &num_keywords);
            } else if (strncmp(trimmed, "\"varname\" : \"title\"", 19) == 0) {
                strncpy(title, last_text, MAX_SINGLE_ELEM_CHARS - 1);
            }
        }
        
    }
    
    
    // copying data
    long this_idx = stats->num_help_modules;
    if (this_idx < MAX_HELP_MODULES) {
        strncpy(stats->help_module[this_idx].filename, filename, MAX_FILENAME_CHARS);
        strncpy(stats->help_module[this_idx].title, title, MAX_SINGLE_ELEM_CHARS);

        stats->help_module[this_idx].num_sections = num_sections;
        for (i = 0; i < num_sections; i++)
            strncpy(stats->help_module[this_idx].section[i], section[i], MAX_SINGLE_ELEM_CHARS);
            
        stats->help_module[this_idx].num_keywords = num_keywords;
        for (i = 0; i < num_keywords; i++)
            strncpy(stats->help_module[this_idx].keyword[i], keyword[i], MAX_SINGLE_ELEM_CHARS);

        stats->help_module[this_idx].num_objects = num_objects;
        for (i = 0; i < num_objects; i++)
            strncpy(stats->help_module[this_idx].object[i], object[i], MAX_SINGLE_ELEM_CHARS);

        stats->help_module[this_idx].num_seealso = num_seealso;
        for (i = 0; i < num_seealso; i++)
            strncpy(stats->help_module[this_idx].seealso[i], seealso[i], MAX_SINGLE_ELEM_CHARS);

        stats->num_help_modules++;
    }
    
    
    for (i = 0; i < MAX_HELP_FILE_PATH_DEPTH; i++)
        free(section[i]);
    for (i = 0; i < MAX_HELP_FILE_NUM_OBJS; i++)
        free(object[i]);
    for (i = 0; i < MAX_KEYWORDS; i++)
        free(keyword[i]);
    for (i = 0; i < MAX_SEEALSO_ELEMS; i++)
        free(seealso[i]);

    fclose(fp_read);
}


void process_help_directory(char *source_folder, char recursive, char *help_router, FILE *output_file, NSTextField *progress_label, NSTextView *error_log, t_doctor_max_help_stats *stats, long num_exclude_files, const char **exclude_files)
{
    DIR *dir;
    struct dirent *ent;
    if (strlen(source_folder) > 0) {
        if ((dir = opendir (source_folder)) != NULL) {
            /* print all the files and directories within directory */
            while ((ent = readdir (dir)) != NULL) {
                char str[FILENAME_MAX];
                long len;
                
                if (!strcmp(ent->d_name, "."))
                    continue;
                
                if (!strcmp(ent->d_name, ".."))
                    continue;
                
                struct stat st;
                lstat(ent->d_name, &st);
                if(ent->d_type == DT_DIR) {
                    if (recursive) {
                        char buf[PATH_MAX + 1];
                        snprintf(buf, PATH_MAX, "%s/%s", source_folder, ent->d_name);
                        //						realpath(ent->d_name, buf); // buf + 60
                        process_help_directory(source_folder, recursive, help_router, output_file, progress_label, error_log, stats, num_exclude_files, exclude_files);
                    }
                } else {
                    
                    strcpy(str, ent->d_name);
                    len = strlen(str);
                    long help_router_len = strlen(help_router);
                    
                    if (help_router_len == 0 || strncmp(str, help_router, strlen(help_router)) == 0) {
                        if (strncmp(str + len - 7, ".maxpat", 7) == 0) {
                            // check if we must exclude it
                            long i;
                            char must_exclude = false;
                            for (i = 0; i < num_exclude_files; i++)
                                if (strcmp(str, exclude_files[i]) == 0) {
                                    must_exclude = true;
                                    break;
                                }
                            
                            
                            // process it
                            if (!must_exclude) {
                                // it's an help center file!
                                process_help_file(str, source_folder, help_router, output_file, progress_label, error_log, stats);
                                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow: 0.01]];
                            } else {
                                [error_log setString:[NSString stringWithFormat: @"%@ %s %s %s\n", [error_log string], "File", str, "will be excluded as requested"]];
                            }
                        }
                    }
                }
            }
            closedir (dir);
        } else {
            /* could not open directory */
            [error_log setString:[NSString stringWithFormat: @"%@ %s %s\n", [error_log string], "Failed to open folder", source_folder]];
        }
    }
}


int help_files_cmp(const void *a, const void *b) {
    t_doctor_max_help_module_stats *aa = (t_doctor_max_help_module_stats *)a;
    t_doctor_max_help_module_stats *bb = (t_doctor_max_help_module_stats *)b;
    
    // comparing 1st level
    int res = strcmp(aa->section[0], bb->section[0]);
    
    long i = 1;
    while (i < MAX_HELP_FILE_PATH_DEPTH) {
        if (res)
            break;
        res = strcmp(aa->section[i], bb->section[i]);
        i++;
    }
    
    return res;
}


char *stringarray_to_string(long num_elems, char str[MAX_KEYWORDS][MAX_SINGLE_ELEM_CHARS])
{
    long i, tot_len = 0;
    for (i = 0; i < num_elems; i++) {
        tot_len += strlen(str[i]);
        tot_len += 6; // double quotes, commas, spaces... it's an upper bound
    }
    
    char *out_str = malloc((tot_len + 1) * sizeof(char));
    memset(out_str, 0, (tot_len + 1) * sizeof(char));
    char *cur = out_str;
    for (i = 0; i < num_elems; i++) {
        cur += sprintf(cur, (i == num_elems - 1 ? "\"%s\"" : "\"%s\", "), str[i]);
    }
    return out_str;
}

void produceHelpFiles(const char *source_folder, char recursive, const char *help_router, const char *output_file, NSTextField *progress_label, NSTextView *error_log, t_doctor_max_help_stats *stats, long num_exclude_files, char **exclude_files)
{
    FILE *fp_write;
    long i, j, k;
    
    if (true) {
        char temp[300];
        snprintf(temp, 299, "%s", output_file);
        [error_log setString:[NSString stringWithFormat: @"%@ A json help center file will be written.\n", [error_log string]]];
        fp_write = fopen(temp, "w");
        
        if (fp_write == NULL)
            [error_log setString:[NSString stringWithFormat: @"%@ Failed to open json help center file for write.\n", [error_log string]]];
    }
    
    if (fp_write) {
        
        
        // Allocating stats memory
        stats->num_help_modules = 0;
        stats->help_module = malloc(MAX_HELP_MODULES * sizeof(t_doctor_max_help_module_stats));
        memset(stats->help_module, 0, MAX_HELP_MODULES * sizeof(t_doctor_max_help_module_stats));
        
        
        // cycling though help files to recover information
        process_help_directory(source_folder, recursive, help_router, fp_write, progress_label, error_log, stats, num_exclude_files, exclude_files);
        
        
        qsort(stats->help_module, stats->num_help_modules, sizeof(t_doctor_max_help_module_stats), help_files_cmp);

        // write information into json
        int depth = 0;
        char curr[MAX_HELP_FILE_PATH_DEPTH][MAX_SINGLE_ELEM_CHARS];
        for (i = 0; i < MAX_HELP_FILE_PATH_DEPTH; i++)
            curr[i][0] = 0;
        
        fprintf(fp_write, "{\n");
        
        
        for (i = 0; i < stats->num_help_modules; i++) {
            for (j = 0; j < MAX_HELP_FILE_PATH_DEPTH; j++)
                if (stats->help_module[i].section[j][0])
                    change_section_name(stats->help_module[i].section[j]);
        }
        
        for (i = 0; i < stats->num_help_modules; i++) {
            t_doctor_max_help_module_stats *m = &stats->help_module[i];
            
            if (strcmp(m->section[0], curr[0])) {
                if (curr[0][0] != 0) { // not the first time
                    if (curr[1][0]) {
                        if (curr[2][0]) {
                            if (curr[3][0]) {
                                fprintf(fp_write, "\t\t\t\t}\n"); // close fourth level
                            }
                            fprintf(fp_write, "\t\t\t}\n"); // close third level
                        }
                        fprintf(fp_write, "\t\t}\n"); // close second level
                    }
                    fprintf(fp_write, "\t},\n"); // close first level
                }
                
                
                fprintf(fp_write, "\t\"%s\" : {\n", m->section[0]); // open first level
                if (m->section[1][0]) {
                    fprintf(fp_write, "\t\t\"%s\" : {\n", m->section[1]); // open second level
                    if (m->section[2][0]) {
                        fprintf(fp_write, "\t\t\t\"%s\" : {\n", m->section[2]); // open third level
                        if (m->section[3][0]) {
                            fprintf(fp_write, "\t\t\t\t\"%s\" : {\n", m->section[3]); // open fourth level
                        }
                    }
                }

            } else if (strcmp(m->section[1], curr[1])) { // second levels differ
                
                if (curr[1][0]) {
                    if (curr[2][0]) {
                        if (curr[3][0]) {
                            fprintf(fp_write, "\t\t\t\t}\n"); // close fourth level
                        }
                        fprintf(fp_write, "\t\t\t}\n"); // close third level
                    }
                    fprintf(fp_write, "\t\t},\n"); // close second level
                }
                
                if (m->section[1][0]) {
                    fprintf(fp_write, "\t\t\"%s\" : {\n", m->section[1]); // open second level
                    if (m->section[2][0]) {
                        fprintf(fp_write, "\t\t\t\"%s\" : {\n", m->section[2]); // open third level
                        if (m->section[3][0]) {
                            fprintf(fp_write, "\t\t\t\t\"%s\" : {\n", m->section[3]); // open fourth level
                        }
                    }
                }

                
            } else if (strcmp(m->section[2], curr[2])) { // third levels differ
                
                if (curr[2][0]) {
                    if (curr[3][0]) {
                        fprintf(fp_write, "\t\t\t\t}\n"); // close fourth level
                    }
                    fprintf(fp_write, "\t\t\t},\n"); // close third level
                }
                
                if (m->section[2][0]) {
                    fprintf(fp_write, "\t\t\t\"%s\" : {\n", m->section[2]); // open third level
                    if (m->section[3][0]) {
                        fprintf(fp_write, "\t\t\t\t\"%s\" : {\n", m->section[3]); // open fourth level
                    }
                }

            } else if (strcmp(m->section[3], curr[3])) { // fourth levels differ
                
                if (curr[3][0]) {
                    fprintf(fp_write, "\t\t\t\t},\n"); // close fourth level
                }
                
                if (m->section[3][0]) {
                    fprintf(fp_write, "\t\t\t\t\"%s\" : {\n", m->section[3]); // open fourth level
                }

            }
            
            // Adding tabs properly
            char tabstr[MAX_LINE_CHARS];
            memset(tabstr, 0, MAX_LINE_CHARS * sizeof(char));
            for (j = 0; j < MAX_HELP_FILE_PATH_DEPTH; j++) {
                if (!m->section[j][0]) {
                    for (k = 0; k < j+1; k++)
                        tabstr[k] = 9; // tab
                    break;
                }
            }
            if (tabstr[0] == 0) {
                for (k = 0; k < MAX_HELP_FILE_PATH_DEPTH+1; k++)
                    tabstr[k] = 9; // tab
            }
            
            // filename
            fprintf(fp_write, "%s\"filename\" : [ \"%s\" ],\n", tabstr, m->filename);
            
            // objects
            char *objs_as_str = stringarray_to_string(m->num_objects, m->object);
            fprintf(fp_write, "%s\"objects\" : [ %s ],\n", tabstr, objs_as_str);
            free(objs_as_str);
            
            // see also
            char *seealso_as_str = stringarray_to_string(m->num_seealso, m->seealso);
            fprintf(fp_write, "%s\"seealso\" : [ %s ],\n", tabstr, seealso_as_str);
            free(seealso_as_str);

            // keywords
            char *keywords_as_str = stringarray_to_string(m->num_keywords, m->keyword);
            fprintf(fp_write, "%s\"tags\" : [ %s ],\n", tabstr, keywords_as_str);
            free(keywords_as_str);
            
            //title
            fprintf(fp_write, "%s\"title\" : [ \"%s\" ]\n", tabstr, m->title);

            
            
            // updates current sections
            for (j = 0; j < MAX_HELP_FILE_PATH_DEPTH; j++)
                strncpy(curr[j], m->section[j], MAX_SINGLE_ELEM_CHARS);
        }
        
        
        if (curr[0][0]) {
            if (curr[1][0]) {
                if (curr[2][0]) {
                    if (curr[3][0]) {
                        fprintf(fp_write, "\t\t\t\t}\n");
                    }
                    fprintf(fp_write, "\t\t\t}\n");
                }
                fprintf(fp_write, "\t\t}\n");
            }
            fprintf(fp_write, "\t}\n");
        }
        
        fprintf(fp_write, "}");
        fclose(fp_write);
    }
}

/// PATREON STUFF

typedef struct _patron {
    char name[128];
    char active;
    short int pledge;
} t_patron;

void producePatronsCode(const char *source_members_CSV, const char *target_file, NSTextView *error_log, char addGpl3License, const char *copyright, short int min_top_supporters_pledge)
{
    FILE *fp_write = fopen(target_file, "w");
    FILE *fp_read = fopen(source_members_CSV, "r");

    if (fp_read == NULL) {
        [error_log setString:[NSString stringWithFormat: @"%@ Failed to open members CSV file for read.\n", [error_log string]]];
        return;
    }

    if (fp_write == NULL) {
        [error_log setString:[NSString stringWithFormat: @"%@ Failed to open patrons.h file for write.\n", [error_log string]]];
        return;
    }


    fprintf(fp_write, "/*\n");
    fprintf(fp_write, " *  patrons.h\n");
    fprintf(fp_write, " * (This file has been generated automatically by Doctor Max. You may not want to edit this file directly).\n");
    fprintf(fp_write, " *\n");
    if (copyright) {
        fprintf(fp_write, " * %s\n", copyright);
        fprintf(fp_write, " *\n");
    }
    if (addGpl3License) {
        fprintf(fp_write, " * This program is free software: you can redistribute it and/or modify it\n");
        fprintf(fp_write, " * under the terms of the GNU General Public License\n");
        fprintf(fp_write, " * as published by the Free Software Foundation,\n");
        fprintf(fp_write, " * either version 3 of the License, or (at your option) any later version.\n");
        fprintf(fp_write, " * This program is distributed in the hope that it will be useful,\n");
        fprintf(fp_write, " * but WITHOUT ANY WARRANTY; without even the implied warranty of\n");
        fprintf(fp_write, " * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.\n");
        fprintf(fp_write, " * See the GNU General Public License for more details.\n");
        fprintf(fp_write, " * You should have received a copy of the GNU General Public License\n");
        fprintf(fp_write, " * along with this program.\n");
        fprintf(fp_write, " * If not, see <https://www.gnu.org/licenses/>.\n");
    }
    fprintf(fp_write, " *\n");
    fprintf(fp_write, " */\n");
    fprintf(fp_write, "\n");
    fprintf(fp_write, "/**\n");
    fprintf(fp_write, " @file    patrons.h\n");
    fprintf(fp_write, " @brief    Code to post current patrons\n");
    fprintf(fp_write, " */\n");

    fprintf(fp_write, "\n");
    fprintf(fp_write, "#include \"ext.h\"\n");
    fprintf(fp_write, "\n");

    char buf[8192];
    t_patron patrons[256];
    long i = 0;
    int p = 0;
    long name_col = 0, status_col = 3, pledge_col = 6;
    while (fgets(buf, sizeof(buf), fp_read) != NULL)
    {
        int j = 0;

        char *string, *tofree, *token;
        tofree = string = strdup(buf);
        // loop through the string to extract all other tokens
        while ((token = strsep(&string, ",")) != NULL) {
            if (i == 0) { // first line
                if (strcmp(token, "Name") == 0)
                    name_col = j;
                else if (strcmp(token, "Patron Status") == 0)
                    status_col = j;
                else if (strcmp(token, "Pledge $") == 0)
                    pledge_col = j;
            } else {
                if (j == name_col)
                    strncpy(patrons[p].name, token, MIN(strlen(token)+1, 128));
                if (j == status_col)
                    patrons[p].active = (strcmp(token, "Active patron") == 0) ? 1 : 0;
                if (j == pledge_col)
                    patrons[p].pledge = atol(token+1);
            }
            j++;
        }
        free(tofree);
        if (i != 0)
            p++;
        i++;
    }
    
    long count_top = 0;
    long count_active = 0;
    
    fprintf(fp_write, "void post_top_supporters()\n");
    fprintf(fp_write, "{\n");
    for (long i = 0; i < p; i++) {
        if (patrons[i].active && patrons[i].pledge >= min_top_supporters_pledge) { // top supporters
            count_top++;
            fprintf(fp_write, "\tpost(\"- %s\");\n", patrons[i].name);
        }
    }
    fprintf(fp_write, "}\n");

    fprintf(fp_write, "\n");
    
    fprintf(fp_write, "void post_all_patrons()\n");
    fprintf(fp_write, "{\n");
    const long max_line_len = 128;
    buf[0] = 0;
    long cur = 0;
    long last_active = 0;
    for (long i = 0; i < p; i++) {
        if (patrons[i].active)
            last_active = i;
    }
    for (long i = 0; i < p; i++) {
        if (patrons[i].active) {
            count_active++;
            if (cur + strlen(patrons[i].name) > max_line_len) {
                if (cur > 0) {
                    fprintf(fp_write, "\tpost(\"%s\");\n", buf);
                    cur = sprintf(buf, "%s, ", patrons[i].name);
                } else { // name too long
                    fprintf(fp_write, "\tpost(\"%s%s\");\n", patrons[i].name, i==last_active ? "." : ", ");
                }
            } else {
                cur += sprintf(buf+cur, "%s%s", patrons[i].name, i==last_active ? "." : ", ");
            }
        }
    }
    if (buf[0]) {
        fprintf(fp_write, "\tpost(\"%s\");\n", buf);
    }
    fprintf(fp_write, "}\n");

    [error_log setString:[NSString stringWithFormat: @"%@ Correctly exported code for %ld patrons (of which %ld top supporters).\n", [error_log string], count_active, count_top]];
    
    fclose(fp_write);
    fclose(fp_read);
}
                  
