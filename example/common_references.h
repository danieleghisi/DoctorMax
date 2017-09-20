/**
	@file	common_doc.h
	@brief	Common documentation concepts
*/


#define COMMON_DOC_RANDOM_OUTPUT
	//  This is a common documentation snippet, which will be copied when one uses the "copy" tag, referencing the name "COMMON_DOC_RANDOM_OUTPUT".
	//  It is meant to be some sort of documentation you need more than once, so that it is easier to maintain.
	//  You can also recursively use the "copy" tag inside common snippets, for instance:
	//  @copy COMMON_DOC_MAXFACTOR
	//  It can be a good rule to terminate each common snipped with a line break, or a double line break, so that listed "copy" elements
	//  are formatted in a cleaner way:
	//  @copy COMMON_DOC_MAXFACTOR
	//  @copy COMMON_DOC_MAXFACTOR
	//  <br />


#define COMMON_DOC_MAXFACTOR
	//  The <m>maxfactor</m> is the maximum random factor for the multiplication. The actual factor will be chosen randomly by <o>_NAME</o> from 1 to the 
	//  specified integer value.
	//  Notice that you can use the variable NAME with an underscore right before in order to have it as a placeholder which will be substituted
	//  with the object name (for any object in which this snipped is used). For instance: this snipped is used right now in the object _NAME.
	//  You might usually want to use such specification inside "o" angular bracket tags.
	//  This is handy if you have portion of common documentation referring to more than one object.
	//  <br />
