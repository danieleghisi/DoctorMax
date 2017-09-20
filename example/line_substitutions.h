/**
	@file	substitutions.h
	@brief	Substitutions of common lines
*/


// If you have some line which are shared by multiple objects (e.g. an attribute which is declared commonly)
// a good way to go is to define substitutions line, i.e. lines which are tried to be matched in any main file
// and replaced with the defined ones. You do so by using the #define clause, as shown below.
// You don't need to put entire lines after the "#define", as the match will be performed on the number of written characters.
// For instance, if you put "#define add_foo_common_attribute", this will match
// "add_foo_common_attribute(c)" as well as "add_foo_common_attribute(c, FOO)" and so on.

#define add_foo_common_attribute
CLASS_ATTR_CHAR(c, "foo", 0, t_your_common_structure, foo); 
CLASS_ATTR_STYLE_LABEL(c,"foo",0,"onoff","Foo Common Attribute");
CLASS_ATTR_BASIC(c,"foo",0);
// @description Here you can document the attribute, which might be shared by multiple objects
