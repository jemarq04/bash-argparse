# Bash Argument Parser (BAP)

This repository contains the script necessary to implement argument parsing in your own bash script. All that needs to be done is to move `BashArgParse` 
into your `PATH` and add `source BashArgParse` at the beginning of your bash script. **NOTE:** This can only be done the main body of a bash script,
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
bap_add_bflag -a/--admin "if given, the user is given admin status"

# Maybe we also want the age of the user. Let's add an integer flag. Let's make this one required.
bap_add_iflag -g/--age 1 true "age of the user"

# Now let's ask for the most important stuff. We'll make these positional arguments.
bap_add_posarg username "username for the user"
bap_add_posarg password "password for the user"

bap_parse "$@" # We call this at the end to parse the command-line arguments. Note the double-quotes!

# Here's where we would add the logic for our program. But first, we need the variables given by the user.

email=$(bap_get --email) && [[ -z $email ]] && email="NONE"
# Or we can run the following: email=$(bap_get_else --email "NONE")
admin=$(bap_get -a/--admin) && [[ -z $admin ]] && admin=false
# Once again, we can also run: admin=$(bap_get_else --admin)
age=$(bap_get --age) # This is required, so no need to check if it's blank!
username=$(bap_get username)
password=$(bap_get password)

# Now that we have all the information we need, we would add the rest below.

```

## Function Documentation

There are several functions that are in BAP that will make your job making your script easier. I'll explain them here:

* `bap_error`: 
Use this function to print an error message after a usage string and exit your script. The error message depends on the usage. 
  * Usage:
    * `bap_error`: Prints `error` and exits the script.
    * `bap_error "$message"`: Prints `error: $message` and exits the script.
    * `bap_error $arg "$message"`: Prints `error: argument $arg: $message` and exits the script.

* `bap_set_prefix`:
Use this function to list the valid prefix characters for flags in your script. By default, this is set to only dashes. If you wish to allow both
dashes and plus signs, you can run `bap_set_prefix "-+"`.
  * Usage: `bap_set_prefix $chars`.

* `bap_set_name`:
Use this function to set the name of the running script. This is **required** for the program to format properly.
  * Usage: `bap_set_name $0` or `bap_set_name $name`.
    * For the script to automatically get the running script's name, run `bap_set_name $0`.
    * If you wish to name the script something differently for any reason, you can provide a different name.
  **NOTE:** This will not change how the script is executed from the terminal!

* `bap_get_name`:
Use this function to retrieve the name of the running script. This will return an empty string before `bap_set_name` is called. 
  * Usage: `bap_get_name`.

* `bap_set_desc`:
Use this function to set the description for your script. The description string will be automatically formatted based on 
the given line length limit. This is not required to run your script.
  * Usage: `bap_set_desc $desc`.

* `bap_set_epilog`:
Use this function to set an additional description after the help messages of each of the arguments. The epilog will similarly be automatically
formatted based on the given line length limit and will not be required to run your script.
  * Usage: `bap_set_epilog $epilog`.

* `bap_set_line_cap`:
Use this function to change the line length limit of the help/usage strings. (Default: 70) 
  * Usage: `bap_set_line_cap $num`.

* `bap_set_help`:
Use this function to change the help string manually. Note that this will prevent BAP from dynamically adding to the help string as you add arguments
to your script.
  * Usage: `bap_set_help $helpstr`.

* `bap_get_usage`:
Use this function to retrieve the usage string. To preserve whitespace on `echo` statements, be sure to enclose it in double quotes.
  * Usage: `bap_get_usage`.
    * For example,
	```sh
	usage_var=$(bap_get_usage)
	echo "$usage_var"
	```

* `bap_get_help`:
Use this function to retrieve the help string. This includes the usage string, the description, and the help messages for each of the arguments. The
epilog statement will additionally be provided if it has been given. To preserve whitespace on `echo` statements, be sure to enclose it in double 
quotes (just like `bap_get_usage`).
  * Usage: `bap_get_help`.

* `bap_add_help`:
Use this function to add a `-h/--help` flag into your script that will print the help message and exit when given.
  * Usage: `bap_add_help`.

* `bap_add_version`:
Use this function to add a `--version` flag into your script that will print the given version string and exit when given.
  * Usage: `bap_add_version $version`.

* `bap_add_iflag`: 
Use this function to add an integer flag to your script.
  * Usage: `bap_add_iflag $arg $nargs $required "$message" [$metavarlist]`.
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
  * Usage: `bap_add_fflag $arg $nargs $required "$message" [$metavarlist]`.

* `bap_add_sflag`:
Use this function to add a string flag to your script. The usage is the same as that for integer flags above.
  * Usage: `bap_add_sflag $arg $nargs $required "$message" [$metavarlist]`.

* `bap_add_bflag`:
Use this function to add a boolean flag to your script. The usage is the same as that for integer flags above, but omits `$nargs` and `[$metavarlist]`
because boolean flags take no arguments. As it would be odd to require a boolean flag, this has also been omitted. 
  * Usage: `bap_add_bflag $arg "$message"`.

* `bap_add_posarg`:
Use this function to add a positional argument to your script. Unlike some argument parsers, you can set whether or not the positional
argument is required. Note that required positional arguments cannot follow optional positional arguments. If you wish to designate a 
positional argument as an integer argument, you must do the error checking using the functions added in version 2.1.0 given in "More 
Helper Functions", as BAP does not keep track of positional argument datatypes. Note that positional arguments can also have metavariables,
but, similarly to flags, they cannot be used to retrieve the value provided by the user.
  * Usage: `bap_add_posarg $posarg $required "$message" [$metavar]`.

* `bap_parse`:
Use this function to parse the command line arguments. This is done **after** you have added all of the flags and positional arguments necessary
for your script. The `$@` variable must be encased in double quotes to preserve whitespaces in certain arguments. (Note: If you want to have 
positional arguments that begin with the prefix characters, it may be useful to denote the beginning of the positional arguments with the
pseudo-optional argument `--`. For example, `PROG.sh --num=3 -- -a three`. In the example, both `-a` and `three` are stored into their respective
positional arguments.)
  * Usage: `bap_parse "$@"`.

* `bap_get`:
Use this function to retrieve the value of a given optional/positional argument. If the argument was not given, the value retrieved will be blank.
  * Usage: `bap_get $arg`.
    * To preserve whitespaces in multi-value string flags, there is an exception to retrieving their values. To access the ith element (indexed at 0),
  you must call `bap_get $arg $i`. To get the number of arguments provided, you can run `bap_get_len` below.
  
* `bap_get_len`:
Use this function to retrieve the number of values that a given argument takes. This is primarily so that string values can be accessed,
but this function works with any given argument provided.
  * Usage: `bap_get_len $arg`.

### More Helper Functions

With the introduction of BAP 2.1.0, more helper functions were added to make common checks in your script easier. I'll describe them below:

* `bap_get_int`:
Use this function to retrieve the value of a given optional/positional argument (if and only if it is an integer). This function is identical to 
`bap_get`, except that it will throw an error through `bap_error` if the given argument is not an integer. Since this function checks if the given argument
is an integer, it also assumes that there is only one value and does not take an index `$i`. This is ideally for use with positional arguments,
which have no internal property for datatype, but is usable with flags as well.
  * Usage: `bap_get_int $arg`.

* `bap_get_float`:
Use this function to retrieve the value of a given optional/positional argument (if and only if it is a float). This function is the same as
`bap_get_int`, except that it will check for a float rather than an integer.
  * Usage: `bap_get_float $arg`.

* `bap_get_else`:
Use this function to retrieve the value of a given optional flag (or positional argument). If the optional flag (or positional argument) was 
not provided by the user, this function will return the default value you provide. If a default value is not provided, the function will use `false`. 
  * Usage: `bap_get_else $arg [$default]`.

* `bap_get_choice`:
Use this function to retrieve the value of a given argument. If the argument is not one of the given choices you provide, it will throw an error.
  * Usage: `bap_get_choice $arg $choice1 $choice2 ...`.

## Subparsers

There is also basic capability for "subparsers" in your scripts. (For example, `add` in the command `git add` will parse arguments differently than
`commit` in `git commit`.) To do this, you simply need to create a script for each subcommand you wish to run. There are also different commands
specific to subparsers that will need to be used. To see how this works, let's look at the following example.

### Subparsers: Example Setup

If you are still unfamiliar with how BAP works, see the first example setup at the beginning of this document. 
To see in-depth explanations of the subparser functions, see the section below. Let's say we want to create a script 'foo' which will have subcommands
'bar' and 'baz'. We would then construct our file `foo` as follows.

```sh
#!/bin/bash
#File: foo

source BashArgParse

bap_set_name $0
bap_set_desc "A sample command with subcommands."

# We can add as many flags as we want, including 'help' and 'version'.
bap_add_help 
bap_add_bflag "-v/--verbose" "print lots of foo and bar. maybe even baz."

# Note you cannot add positional arguments in the base command!

# Here are the two special functions for the base command.
bap_add_subparsers bar baz	# This function allows you to enumerate the subparsers available.
bap_parse "$@"
bap_subparse "$@"		# This function will automatically call the subcommand you need.
```

If you want the filename of the subcommand, you can also run `bap_get_subparser`. Alternatively, you can retrieve the name of the subcommand itself
chosen by the user by running `bap_get subcommand`.

Now we need to create two separate files for each of the subcommands. The name of these files must be the main command followed by a dash and the
subcommand name. For example, here we would need to create `foo-bar` and `foo-baz`. (Note, we can also create `foo-bar.sh` and `foo-baz.sh` instead.
The file extensions can always be used if preferred.)
You construct the subcommand scripts the same as you would any other BAP script, but instead of the usual `bap_set_name $0` call, you should call
`bap_set_subname $0` for the usage string to print properly. 

### Subparsers: Function Documentation

* `bap_set_subname`:
Use this function to set the name of the running subcommand script. For a subcommand script named `foo-bar.sh`, this function will set the name of the command in
the usage string as `foo bar` automatically for you. (Note that either `bap_set_name` or `bap_set_subname` **MUST** be run for BAP to run properly.)
  * Usage: `bap_set_subname $0` or `bap_set_subname $name`.
    * For the script to automatically get the running script's name, run `bap_set_subname $0`.
    * If you wish to name the script something differently for any reason, you can provide a different name.

* `bap_get_subname`:
Use this function to retrieve the name of the running subcommand script as it appears in the usage string. For a subcommand script named `foo-bar.sh`,
this function would return `foo bar` (or `foo.sh bar`, if the base script is named `foo.sh`). This will return an empty string if `bap_set_subname` has not been called. Note that if you want to retrieve
the name of the base script, call `bap_get_name` instead.
  * Usage: `bap_get_subname`.

* `bap_add_subparsers`:
Use this function to add subcommands to your script. Note that files for each subcommand must be present in the directory of your base script. 
  * Usage: `bap_add_subparsers $subparser1 [$subparser2] ...`.

* `bap_get_subparser`:
Use this function to retrieve the filename of the subcommand you want to run. This may be useful if you want the call to be different based on the
flags given for the base command.
  * Usage: `bap_get_subparser`.

* `bap_subparse`:
Use this function after `bap_parse "$@"` to automatically run the necessary subcommand based on the choice given by the user.
  * Usage: `bap_subparse "$@"`.
