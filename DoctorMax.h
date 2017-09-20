//
//  DoctorMax.h
//  DoctorMax
//
//  Created by Daniele Ghisi on 15/01/16.
//
//

#ifndef DoctorMax_h
#define DoctorMax_h

#define false 0
#define true 1

// This flag must only be defined when using Doctor Max while compiling references of the bach library:
#define BACH_REF

// Only used by bach (somehow private)
#define SOURCES_PATH_NOTATION_MAXINTERFACE "/Users/danieleghisi/Documents/Max 7/Packages/bach/source/commons/dg/notation_maxinterface.c"
#define BACH_TUTORIAL_FOLDER "/Users/danieleghisi/Documents/Max 7/Packages/bach/docs/tutorials/bach-tut"
#define SOURCES_PATH_DADA_OBJ_COMMONS "/Users/danieleghisi/max-sdk-7.0.3/source/dada/commons/dada.object.c"

#define MAX_DESCRIPTION_LINES 800
#define MAX_DISCUSSION_LINES 100
#define MAX_INLETS 15
#define MAX_OUTLETS 15
#define MAX_ARGUMENTS 6
#define MAX_METHOD_ARGUMENTS 10
#define MAX_METHOD_ATTRIBUTES 16
#define MAX_METHODS 200		// In "debug x86_64 mode" CAN'T BE MORE THAN 40andcounting.. WHY??? // 40
#define MAX_METHOD_EXAMPLES 80
#define MAX_METHOD_SEEALSO_ELEMS 50
#define MAX_ATTRIBUTES 340	// In "debug x86_64 mode" CAN'T BE MORE THAN 72... WHY??? // 72
#define MAX_LINE_CHARS 300
#define MAX_SINGLE_ELEM_CHARS 80
#define MAX_FILENAME_CHARS 200
#define MAX_COMMON_REFERENCE_LINES 600
#define MAX_SEEALSO_ELEMS 100
#define MAX_KEYWORDS 100
#define MAX_RECURSION_DEPTH_FOR_COPYING 30
#define MAX_SUBSTITUTIONS 30
#define MAX_CATEGORIES 30
#define MAX_MODULES 500
#define MAX_HELP_MODULES 1500
#define MAX_HELP_EXCLUDE 50

#define MAX_HELP_FILE_PATH_DEPTH 5
#define MAX_HELP_FILE_NUM_OBJS 10


typedef enum _status_values
{
    k_STATUS_OK = 0,				///< Object is documented and fully functional
    k_STATUS_HIDDEN = 1,			///< Undocumented, but fully functional object
    k_STATUS_EXPERIMENTAL = 2,		///< Undocumented because unfinished or experimental object
    k_STATUS_DEPRECATED = 3,		///< Undocumented because deprecated object
} e_status_values;
#define NUM_DOCTOR_MAX_MODULE_STATUS 4


typedef enum _types
{
    k_TYPE_OBJECT = 0,
    k_TYPE_ABSTRACTION = 1,
    k_TYPE_OTHER = 2,
} e_types;


typedef struct _doctor_max_module_stat
{
    long idx;
    
    char                  name[MAX_SINGLE_ELEM_CHARS];
    char                  real_name[MAX_SINGLE_ELEM_CHARS];
    char                  c_source[MAX_SINGLE_ELEM_CHARS];
    char                  owner[MAX_SINGLE_ELEM_CHARS];
    char                  digest[MAX_LINE_CHARS];
    e_types               type;
    e_status_values       status;
    
    long num_categories;
    char category[MAX_CATEGORIES][MAX_SINGLE_ELEM_CHARS];
    
    long num_keywords;
    char keyword[MAX_KEYWORDS][MAX_SINGLE_ELEM_CHARS];

    long num_seealso;
    char seealso[MAX_SEEALSO_ELEMS][MAX_SINGLE_ELEM_CHARS];

} t_doctor_max_module_stats;


typedef struct _doctor_max_stats
{
    long num_objects[NUM_DOCTOR_MAX_MODULE_STATUS];        // one entry for each e_doctor_max_module_status
    long num_abstractions[NUM_DOCTOR_MAX_MODULE_STATUS];
    
    long num_modules; // should always be num_objects + num_abstractions
    t_doctor_max_module_stats *module;
} t_doctor_max_stats;





typedef struct _doctor_max_help_module_stats
{
    long num_sections;
    char section[MAX_HELP_FILE_PATH_DEPTH][MAX_SINGLE_ELEM_CHARS];
    
    char filename[MAX_FILENAME_CHARS];
    char title[MAX_SINGLE_ELEM_CHARS];

    long num_objects;
    char object[MAX_HELP_FILE_NUM_OBJS][MAX_SINGLE_ELEM_CHARS];

    long num_keywords;
    char keyword[MAX_KEYWORDS][MAX_SINGLE_ELEM_CHARS];

    long num_seealso;
    char seealso[MAX_SEEALSO_ELEMS][MAX_SINGLE_ELEM_CHARS];
} t_doctor_max_help_module_stats;


typedef struct _doctor_max_help_stats
{
    long num_help_modules; // should always be num_objects + num_abstractions
    t_doctor_max_help_module_stats *help_module;
} t_doctor_max_help_stats;


void split_string(const char *str, char *token, char **array, long max_num_splitted_elems, long *num_splitted_elems);

void produceFiles(char export_XMLs, char export_TXTs,
                  const char *sources_folder1, const char *sources_folder2, const char *sources_folder3, const char *sources_folder4,
                  char folder1_recursive, char folder2_recursive, char folder3_recursive, char folder4_recursive,
                  const char *common_ref_file1, const char *common_ref_file2, const char *common_ref_file3, const char *substitutions_file, const char *XML_output_folder, const char *init_TXT_output_folder,
                  NSTextField *progress_label, NSProgressIndicator *progress_indicator, NSTextView *error_log,
                  char sort_methods, char sort_attributes, char export_in_out_as_misc, char export_discussion_as_misc,
                  const char *library_name, char write_database_init, char write_objectlist_init, char write_objectmappings_init,
                  char separate_objs_and_abstrs_in_objlist, char write_c74contents, const char *interfaces_JSON_output_folder, char write_object_qlookup, const char *math_category, NSTextField *overview_label, t_doctor_max_stats *stats,
                  char add_syntax_before_method_description, char for_bach);


void produceHelpFiles(const char *source_folder, char recursive, const char *help_router, const char *output_file, NSTextField *progress_label, NSTextView *error_log, t_doctor_max_help_stats *stats, long num_exclude_files, char **exclude_files);



#endif /* DoctorMax_h */
