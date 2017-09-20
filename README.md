# DoctorMax
Doctor Max: easier documentation for Max libraries

WHAT TO DO TO USE THE APPLICATION

1. Set up your package's doc folder. 
You find the template of a doc folder with the application. Unzip it and put it at the root folder of your package.
- Open docs/refpages/_c74_ref_modules.xml search for "yourlibrary_ref" and replace "yourlibrary" with the name of your library.
- Rename the folder docs/refpages/yourlibrary_ref accordingly.

2. Comment your code.
Open example/testrefgentimes.c and learn how your code should be commented. If you'll need to use common snippets, also have a look at example/common_doc.h
Comment your own code likewise

3. Run Doctor Max.
- Choose the folder where your files are (possibly tick "Subfolders" if you need them to be recursively explored)
- Set as "Output directory for XML reference files" the directory "/docs/refpages/yourlibrary_ref".
- Set as Output directory for "init" TXT files the "init" folder of your package (if you have no "init" folder at the root level of your package, create it!)
- Set as Output directory for "interfaces" JSON file the "interfaces" folder of your package (if you have no "interface" folder at the root level of your package, create it!)
- Don't forget to set the library name in the Preference pane before hitting the "Run" button.

4. To see more examples, you can download the cage library (www.bachproject.net/cage), containing the Doctor Max sources for all of its abstractions, as "dummy" .c files)
