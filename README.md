PDFGenerator
============
Making use of the number tags from the UIView PDFGenerator will make an pdf page from an XIB file

USE OF TAGS
-----------
For static labels set the tag to 1
This will render the label as is in the xib view

For dynamic labels that you have to populate with another name set it tag to 2

MAKING TABLES
-------------
To make tables you will need to set the first collumn of the table with tag 4 and the other columns tag 3
this will make a table from the first column to the end of page
