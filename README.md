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
arguments. In these, you will only have to edit the lines ending in an `#editme` comment. These include...

(This README is in progress. Check back soon!)
