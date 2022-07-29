# Bash Argument Parser (BAP)

This repository contains the script necessary to implement argument parsing in your bash script. All that needs to be done is to move `BashArgParse` into
your `PATH` and add `source BashArgParse` at the beginning of your bash script. **NOTE:** This can only be done the main body of a bash script,
not in a function call. There are calls to `exit` that would exit your terminal if used through a function call.

## Using BAP

After sourcing `BashArgParse`, the next step is to set the name of the program by adding `bap_set_name $0`. After that, add as many flags
and positional arguments as you see fit. Finally, add `bap_parse "$@"` to parse the command-line arguments provided.

To retrieve the values of the optional/positional arguments, use `bap_get` and `bap_get_len` as needed. 
To throw an error and print a message with the required usage for your script, use the `bap_error` function. 
To see how to use all of the functions at your disposal, read the following section.

### Example Setup

To see in-depth explanations of each of the functions, look below in 'Function Documentation.' For a general example of how this program works,
I've created a simple example below. 

Let's say we wanted a script to create a user. We will need a username and a password. Maybe we also need an email for records, and some other information.
We would set this up in some `user.sh` file below:

```sh
#!/bin/bash

source BashArgParse # This brings everything into scope that we would need to create our script.

bap_set_name $0 # This is a required function call so BAP knows the name of your script.
bap_set_desc "This is a description of the script you are creating. It will appear in the help screen."

bap_add_help # This would add the '-h/--help' flag into your script.
bap_add_version "Version 2.0" # This is in case a version string is useful for your script.

# Now, let's add important flags. Let's say that the email is OPTIONAL. Let's create a string flag for it. See the documentation for more information.
bap_add_sflag --email 1 false "user's email" "youremail@website.com"

# We may also need to know if this user is an administrator of sorts. Let's add a boolean flag.
bap_add_bflag -a/--admin false "if given, the user is given admin status"

# Maybe we also want the age of the user. Let's add an integer flag. Let's make this one required.
bap_add_iflag -g/--age 1 true "age of the user"

# Now let's ask for the most important stuff. We'll make these positional arguments.
bap_add_posarg username "username for the user"
bap_add_posarg password "password for the user"

bap_parse "$@" # We call this at the end to parse the command-line arguments. Note the double-quotes!

# Here's where we would add the logic for our program. But first, we need the variables given by the user.

email=$(bap_get --email) && [[ -z $email ]] && email="NONE" # By default, the variables will be BLANK if they were not provided. I check and give a default value
admin=$(bap_get -a/--admin) && [[ -z $admin ]] && admin=false
age=$(bap_get --age) # This is required, so no need to check if it's blank!
username=$(bap_get username)
password=$(bap_get password)

# Now that we have all the information we need, we would add the rest below.

```

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
Usage: `bap_add_iflag $arg $nargs $required "$message" [$metavarlist]`.
  * `$arg` is the name of the flag (e.g. `-n/--num`); the flag can be short form (`-n`), long form (`--num`), or both (`-n/--num`) separated by a slash `/`
  * `$nargs` is the number of values the flag takes
  * `$required` is the boolean value for whether or not the flag is required
  * `$message` is the explanation of the flag's purpose
  * `$metavarlist` is an optional comma-separated list of metavariables for the usage/help string. 
  For example, `bap_add_iflag -m/--minmax 2 false "help message"` will be
  ```
    -m/--minmax MINMAX1 MINMAX2:
           help message
  ```
  without the metavariable string. Let's say you wanted to have the first number as the minimum and the second as the maximum. 
  Then, you could run `bap_add_iflag -m/--minmax 2 false "help message" "min,max"`. This would give
  ```
    -m/--minmax min max:
          help message
  ```

* `bap_add_fflag`:
Use this function to add a float flag to your script. The usage is the same as that for integer flags above.
Usage: `bap_add_fflag $arg $nargs $required "$message" [$metavarlist]`.

* `bap_add_sflag`:
Use this function to add a string flag to your script. The usage is the same as that for integer flags above.
Usage: `bap_add_sflag $arg $nargs $required "$message" [$metavarlist]`.

* `bap_add_bflag`:
Use this function to add a boolean flag to your script. The usage is the same as that for integer flags above, but omits `$nargs` and `[$metavarlist]`
because boolean flags take no arguments.
Usage: `bap_add_bflag $arg $required "$message"`.

* `bap_add_posarg`:
Use this function to add a positional argument to your script. Unlike some argument parsers, you can set whether or not the positional
argument is required. Note that required positional arguments cannot follow optional positional arguments.
Currently, positional arguments do not have the ability to check if
an integer/float is provided. Essentially, it will be assumed that the value is a string. If you wish to designate a positional argument
as an integer argument, you must do the error checking using the functions added in version 2.1.0 given in "More Helper Functions".
Usage: `bap_add_posarg $posarg $required "$message"`.

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

### More Helper Functions

With the introduction of BAP 2.1.0, more helper functions were added to make common checks in your script easier. I'll describe them below:

* `bap_get_int`
Use this function to retrieve the value of a given optional/positional argument (if and only if it is an integer). This function is identical to 
`bap_get`, except that it will return an empty string if the given argument is not an integer. Since this function checks if the given argument
is an integer, it also assumes that there is only one value and does not take an index `$i`. This is ideally for use with positional arguments,
which have no internal property for datatype, but is usable with flags as well.
Usage: `bap_get_int $arg`.

* `bap_get_float`
Use this function to retrieve the value of a given optional/positional argument (if and only if it is a float). This function is the same as
`bap_get_int`, excelt that it will checks for a float rather than an integer.
Usage: `bap_get_float $arg`.

* `bap_get_else`
Use this function to retrieve the value of a given optional flag (or positional argument). If the optional flag (or positional argument) was 
not provided by the user, this function will return the default value you provide. 
Usage: `bap_get_else $arg $default`.
