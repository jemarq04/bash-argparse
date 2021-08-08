# Bash Argument Parser (BAP)

This repository contains the scripts necessary to create your own script using Bash Argument Parser (BAP) using two different methods. 
**First Method:** You can use my `setup.py` file to create a file that has all the boilerplate code necessary and add in as much code as it 
can for you (to see what it can do, run `./setup.py --help`). 
**Second Method:** If you'd prefer not to use the python script, simply copy the `template.sh` file and rename it however you'd like 
and copy paste the *Flag Blocks* from the `argparse.sh` file. I will go into more detail into the code and its terminology later.

If you want a simple demonstration of what this parser can do, try running the `argparse.sh` file! To get an idea, run `./argparse.sh --help`.

## Overview
The BAP code is fairly easy to use! For either method you choose, the only code you would need to edit will be found in *code blocks*, 
denoted by long one-line comments surrounding an area. For example, this will be found at the beginning of your script:

```
# SCRIPT OPTIONS ================================================================================
NUM_POS_ARGS=1
DESC=$(printf "")
# ===============================================================================================
```
To add a description to your script and change the number of required positional arguments, just change these variables! 
To change the description, make sure you put your description string *inside* the double quotes. This will allow you to
use newline characters (`\n`) and tab characters (`\t`) in your description!

There will be empty code blocks in the script for you to add your own variables/logic. They do not need to be filled, but are there as a guide to help you
organize your code.

Lastly, the script will also have *flag blocks*. These are the blocks of code (similarly surrounded by the long comments) that implement your optional
arguments (or flags). In these, you will only have to edit the lines ending in an `#editme` comment. The lines are 

* First Line (`arg`): Edit the name of the flag. This can be a short flag (e.g. `-a`), a long flag (e.g. `num`), or both (e.g. `-s/--str`).
* Second line (`nargs`): The number of values this argument takes. For example, I may have a `--minmax` flag that asks for two values: the min, and the max. 
**NOTE:** This line is not present for boolean flags, as `nargs` is zero by default!
* Third line (help message): Edit the string to explain the meaning of the given argument for the user running your script. 
(An optional fourth argument can be given to overwrite the 'metavar' of the values, but more on that and the help message in the 'Functions' section.)
* Last line (getting `argval`): Lastly, you need to use the output (`argval`) however you please. For example, you can create a variable `num` in the 'Script Variables' code block at the beginning of the script and then store `argval` into `num` to have access to it after the parsing is complete.

If you have positional arguments and you want a good help message, make sure you add a `add_help()` function call in 
the 'Positional Arguments' code block near the end of the script! That will be explained in detail in the 'Functions' section.

## Installation/Using BAP

Installation is easy - just download the `setup.py`, `argparse.sh`, and `template.sh` files onto your local computer and follow the following instructions.

### Method #1: `setup.py`

This method is easy: you'll only need the `setup.py` file for it to work. To see how this script works, run `./setup.py --help`. 
You can provide the description and number of arguments for your program using this script. To add integer flags to your
program, for example, you must provide a comma-separated list of the flag names. You could run something like `./setup.py --int-flags="-n/--num,--minmax"` 
and it would create everything necessary for your program to have an integer flag that uses `-n/--num` and another that uses `--minmax`.
The script also has the `--add-help` flag, which will add a `-h/--help` flag into your program that will print an automatically generated 
usage and help message. Again, this will be explained more in detail in 'Functions'. Lastly, just provide a name for the output file for the `progname`
positional argument, and the file will be created for you.

All that's left is going into the program the script has created and editing the lines, where appropriate, labeled with the comment `#editme`. (I search through
my file for instances of `editme` and edit where I'd like.) Then you're all set!

### Method #2: `template.sh` and `argparse.sh`

This method is also easy, but takes longer to complete than Method #1. Copy the `template.sh` file and rename it to whatever name you choose. Then, copy and paste
flag blocks from `argparse.sh` into your script and edit the lines marked with an `#editme` comment. These are covered in the 'Overview' section.

## Functions

There are several functions that are in the script that will make your job making your program easier. I'll explain them here:

* `error`: Use this function to print an error message after a usage string and exit your program. If the function is given...
  * ...0 arguments, the message 'error' is printed.
  * ...1 argument, the message 'error:' is printed followed by the given argument. Usage: `error "Error message"`.
  * ...2 arguments, the message 'error:' is printed followed by the name of the flag (the first argument passed into the function) and the 
  error message (the second argument passed into the function). Usage: `error $arg "Error message"`.

* `add_help`: Use this function to add an explanation to a given flag or positional argument. **NOTE:** Do not remove this line if you don't want to add 
a help message! This function also automatically generates the usage string. Just leave the line as is even if the help message is never used. 
The function takes a variable number of arguments.
  * For optional arguments (flags), the usage is: `add_help $arg $nargs "Help message" "optional,metavar,list"`
    * $arg is the name of the flag (e.g. `-s/--str`)
    * $nargs is the number of values the flag takes
    * "Help message" is the explanation of the flag's purpose
    * "optional,metavar,list" is an optional comma-separated list of metavariables for the usage/help string. 
    For example, `add_help "-m/--minmax" 2 "help message"` will be
    ```
      -m/--minmax MINMAX1 MINMAX2:
             help message
    ```
    without the metavariable string. Let's say you wanted to have the first number as the minimum and the second as the maximum. 
    Then, you could run `add_help "-m/--minmax" 2 "help message" "min,max"`. This would give
    ```
      -m/--minmax min max:
            help message
    ```
  * For positional arguments, the usage is: `add_help $arg "Help message"`. For example, if you were to run `add_help "posarg1" "help me out here!"`
  you would get
  ```
    posarg1:
          help me out here!
  ```

There are other functions in the script, but these are mostly for my own use in writing the parsing logic and the other functions. 
There is no need to call them for you to call them in your progam.
