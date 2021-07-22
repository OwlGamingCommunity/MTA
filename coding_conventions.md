# Introduction to Coding Conventions #

## 1 - What is Coding Convention? ##

Coding conventions are a set of guidelines that recommend programming style, practices and methods for each aspect of a script written in this server. These conventions I want you all to follow cover indentation, comments, declarations, statements, white space, naming conventions, programming practices, programming principles, etc.

These are guidelines for script structural quality. All scripters are highly recommended to follow these guidelines to help improve the readability of server's source code and make the system maintenance and development easier.

## 2 - Why are Coding Conventions so important? ##

Code conventions are important to scripters for a number of reasons:

* 40%-80% of the lifetime we spend on a script goes to maintenance.
* Hardly any complex script or system is maintained for its whole life by the original author.
* Coding conventions improve the readability of the software, allowing scripters to understand new code more quickly and thoroughly.



# II - Explanations #

## 1. Comments ##

A comment is not only be used to disable a block of script but also is used to embed readable annotations in the script .Those annotations are potentially significant to scripters but are ignored by compilers and interpreters.

Comments are added with the purpose of making the script easier to understand. The syntax for comments in LUA is -- at the end of the line or --[[ & ]] at the beginning and at the end of the block.

Example:
![Desert.jpg](http://puu.sh/7Th8w.png)

## 2. Indentation ##

An indent style is a convention governing the indentation of blocks of script to convey the script's structure. Indent style is just one aspect of programming style but it's the only one I need you all to understand and follow.

Indentation is a must when you script in owlgaming scripting team, it better convey the structure of your script to human readers. In particular, indentation is used to show the relationship between control flow constructs such as conditions or loops and code contained within and outside them.

Good example:
![Desert.jpg](http://puu.sh/7TgdL.png)

Bad example:
![Desert.jpg](http://puu.sh/7Tgb5.png)


## 3. Function & variable naming conventions ##

A naming convention is a set of rules for choosing the character sequence to be used for identifiers which denote variables, types, functions, and other entities in scripts.

Reasons for using a naming convention (as opposed to allowing scripters to choose any character sequence) include the following:

* to reduce the effort needed to read and understand the script.
* to enhance script appearance (for example, by disallowing overly long names or unclear abbreviations).



Some of the potential benefits that can be obtained by adopting a naming convention include the following:

* to provide additional information about the use to which an identifier is put;
* to help formalize expectations and promote consistency within the scripting team;
* to enable the use of automated refactoring or search and replace tools with minimal potential for error;
* to enhance clarity in cases of potential ambiguity;
* to enhance the aesthetic and professional appearance of script (for example, by disallowing overly long names, comical or "cute" names, or abbreviations);
* to provide meaningful data to be used in script handovers which require submission of source code as you will have to post on this forum sometimes.
* to provide better understanding in case of code reuse after a long interval of time.


The choice of naming conventions can be an enormously controversial issue. However, there will be no issue if you follow this convention I set here:

1. Resource, Function & Variable need to be short and descriptive.
1. Function have first character of the word in upper case while other characters are in lower case, except the first word.
1. Resource have all characters of the word in lower case.
1. Good examples of function & variable naming: isPlayerStaff(), isElementProcessed(), openInterior(), closeInventory(), getVehicle(), dateOfMonth, leapYear, terryBear.
1. Bad examples of function & variable nameing: a12, x2, x3, doIt(), finishingStuff(), StartProcessing(), GETTHERE().

## 4. Versioning Convention ##
For global server script version:
A.B.C.D in which:
* 10 D units equal to 1 C unit; 10 C units equal to 1 B unit and so on.;
* 1 D unit equals to 1 minor change/fix.;
* 1 C unit equals to 1 newly created script/system/major change.;

For single script/system version
A.B in which
* 10 B units equal to 1 A unit.;
* Even version means stable version.;
* Odd version means unstable/stresstesting version.;

The purposes of versioning is to let you know how much has been updated compared to previous versions and to let you know how complete a single script/system you're using is.
