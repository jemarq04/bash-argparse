# Bash Argument Parser (BAP)

This repository contains the script necessary to implement argument parsing in your bash script. All that needs to be done is to move `BashArgParse` into
your `PATH` and add `source BashArgParse` at the beginning of your bash script.

## Using BAP

After sourcing `BashArgParse`, the next step is to set the name of the program by adding `bap_set_name $0`. After that, add as many flags
and positional arguments as you see fit. Finally, add `bap_parse "$@"` to parse the command-line arguments provided.

To retrieve the values of the optional/positional arguments, use `bap_get` and `bap_get_len` as needed. To see how to use all of the functions 
at your disposal, read the following section.

To throw an error and print a message with the required usage for your script, use the `bap_error` function.

## Function Documentation

There are several functions that are in the script that will make your job making your script easier. I'll explain them here:

* `bap_error`: 
Use this function to print an error message after a usage string and exit your script. The error message depends on the usage. Usage:
  * `bap_error`: Prints `error` and exits the script.
  * `bap_error "$message"`: Prints `error: $message` and exits the script.
  * `bap_error $arg "$message"`: Prints `error: argument $arg: $message` and exits the script.

* `bap_set_name`:
Use this function to set the name of the running script. This is **required** for the program to format properly.
Usage: `bap_set_name $0` or `bap_set_name $name`.
  * For the script to automatically get the running script's name, run `bap_set_name $0`.
  * If you wish to name the script something differently for any reason, you can provide a different name.
  **NOTE:** This will not change how the script is executed from the terminal!

* `bap_set_desc`:
Use this function to set the description for your script. The description string will be automatically formatted based on 
the given line length limit. This is not required to run your script.
Usage: `bap_set_desc $desc`.

* `bap_set_line_cap`:
Use this function to change the line length limit of the help/usage strings. (Default: 70) 
Usage: `bap_set_line_cap $num`.

* `bap_add_help`:
Use this function to add a `-h/--help` flag into your script that will print the help message and exit when given.
Usage: `bap_add_help`.

* `bap_add_version`:
Use this function to add a `--version` flag into your script that will print the given version string and exit when given.
Usage: `bap_add_version $version`.

* `bap_add_iflag`: 
Use this function to add an integer flag to your script.
Usage: `bap_add_iflag $arg $nargs "$message" [$metavarlist]`.
  * `$arg` is the name of the flag (e.g. `-n/--num`)
  * `$nargs` is the number of values the flag takes
  * `$message` is the explanation of the flag's purpose
  * `$metavarlist` is an optional comma-separated list of metavariables for the usage/help string. 
  For example, `bap_add_iflag -m/--minmax 2 "help message"` will be
  ```
    -m/--minmax MINMAX1 MINMAX2:
           help message
  ```
  without the metavariable string. Let's say you wanted to have the first number as the minimum and the second as the maximum. 
  Then, you could run `bap_add_iflag -m/--minmax 2 "help message" "min,max"`. This would give
  ```
    -m/--minmax min max:
          help message
  ```

* `bap_add_fflag`:
Use this function to add a float flag to your script. The usage is the same as that for integer flags above.
Usage: `bap_add_fflag $arg $nargs "$message" [$metavarlist]`.

* `bap_add_sflag`:
Use this function to add a string flag to your script. The usage is the same as that for integer flags above.
Usage: `bap_add_sflag $arg $nargs "$message" [$metavarlist]`.

* `bap_add_bflag`:
Use this function to add a boolean flag to your script. The usage is the same as that for integer flags above, but omits `$nargs` and `[$metavarlist]`
because boolean flags take no arguments.
Usage: `bap_add_bflag $arg "$message"`.

* `bap_add_posarg`:
Use this function to add a positional argument to your script. Currently, positional arguments do not have the ability to check if
an integer/float is provided. Essentially, it will be assumed that the value is a string. If you wish to designate a positional argument
as an integer argument, you must do the error checking yourself. (To be added.)
Usage: `bap_add_posarg $posarg "$message"`.

* `bap_parse`:
Use this function to parse the command line arguments. This is done **after** you have added all of the flags and positional arguments necessary
for your script. The `$@` variable must be encased in double quotes to preserve whitespaces in certain arguments.
Usage: `bap_parse "$@"`.

* `bap_get`:
Use this function to retrieve the value of a given optional/positional argument. If the argument was not given, the value retrieved will be blank.
Usage: `bap_get $arg`.
  * To preserve whitespaces in multi-value string flags, there is an exception to retrieving their values. To access the ith element (indexed at 0),
  you must call `bap_get $arg $i`. To get the number of arguments provided, you can run `bap_get_len` below.
  
* `bap_get_len`:
Use this function to retrieve the number of values that a given argument takes. This is primarily so that string values can be accessed,
but this function works with any given argument provided.
Usage: `bap_get_len $arg`.
