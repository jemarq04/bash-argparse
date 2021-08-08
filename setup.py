#!/usr/bin/python
import argparse
import os, stat

def main():
	DESC="This program sets up a bash argument parser automatically.\
			NOTE: The only thing that it doesn't account for is HELP\
			information for each argument and $nargs, which must be\
			edited manually."
	NAME = "#Bash Argument Parser (BAP) v1.5.0\n"

	parser = argparse.ArgumentParser(description=DESC, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
	parser.add_argument("--version", action="version", version="Bash Argument Parser (BAP) v1.5.0", help="print the version and exit")
	parser.add_argument("--desc", type=str, default="", help="program description")
	parser.add_argument("--add-help", action="store_true", help="if given, will add help to the program")
	parser.add_argument("--int-args", type=str, default="", help="comma-separated list of single integer arguments (examples: -n/--num or -n or --num)")
	parser.add_argument("--float-args", type=str, default="", help="comma-separated list of single float arguments (examples: -f/--float or -f or --float)")
	parser.add_argument("--str-args", type=str, default="", help="comma-separated list of single string arguments (examples: -s/--str or -s or --str)")
	parser.add_argument("--bool-args", type=str, default="", help="comma-separated list of boolean flags (examples: -a/--a-flag or -a or --a-flag")
	parser.add_argument("--num", type=int, default=0, help="number of required positional arguments")
	parser.add_argument("progname", type=str, help="name of the program")
	args = parser.parse_args()
	
	#bring in string args, then int args, then float args, bool args
	
	if args.int_args == "" and args.float_args == "" and args.str_args == "" and args.bool_args == "" and not args.add_help and args.num == 0:
		parser.error("at least one argument is required for this to be necessary")
	
	outfile = "%s.sh" % args.progname

	try:
		if os.path.isfile(outfile):
			choice = raw_input("Overwrite %s (y/n): " % outfile)
			if choice != 'y':
				return
		
		with open(outfile, "w") as fout:
			fout.write(header(args.num, args.desc, NAME))
			if args.add_help:
				fout.write(helparg())
			fout.write(strargs(args.str_args))
			fout.write(intargs(args.int_args))
			fout.write(floatargs(args.float_args))
			fout.write(boolargs(args.bool_args))
			fout.write(footer(args.num))
		
		os.chmod(outfile, stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR | stat.S_IRGRP | stat.S_IROTH)
	except IOError as x:
		parser.error(x)
	

def header(num, desc, name):
	result='''#!/bin/bash
%s
USAGE="usage: `basename $0`"
USAGE_LEN=0
USAGE_CAP=30
HELP=""
PARAMS=""
FLAG_LIST=""
LONG_FLAG_LIST=""
SHIFT_NUM=1
ADDED_FLAG_HELP=false
ADDED_POSARG_HELP=false
FOUND_FLAG=false
FOUND_HELP=false
PRINT_HELP=false
BEGIN=false

# SCRIPT OPTIONS ==========================
NUM_POS_ARGS=%i
DESC=$(printf "%s")
# =========================================

# SCRIPT VARIABLES ==============================================================================

# ===============================================================================================

function die { echo "$USAGE"; echo $@ >&2; exit 1; }
function error {
	[[ $# -eq 0 ]] && die "error"
	[[ $# -eq 1 ]] && die "error: $1"
	die "error: argument $1: $2"
}
function check_lists { 
	[[ $# -ne 2 ]] && error "check_lists() requires two arguments"
	if [[ ! $1 =~ ^-- ]]; then
		[[ $FLAG_LIST = *"${1:1}"* ]] && error "duplicate flag $1"
		FLAG_LIST="${1:1} $FLAG_LIST"
	fi
	if [[ ${2:0:2} = "--" ]]; then
		[[ $LONG_FLAG_LIST = *"$2"* ]] && error "duplicate long flag $2"
		LONG_FLAG_LIST="$2 $LONG_FLAG_LIST"
	fi
}
function add_help {
	[[ -z $1 ]] && error "add_help() requires 3-4 arguments for flags, 2 arguments for positional arguments"
	
	if [[ ${1:0:1} = "-" ]]; then
		[[ $# -lt 3 || $# -gt 4 ]] && error "add_help() requires 3-4 arguments for flags"
		$ADDED_FLAG_HELP || HELP=$(printf "$HELP\noptional arguments:")
		ADDED_FLAG_HELP=true

		local helpstr=$(printf "\n  $1")
		local first=`cut -d / -f 1 <<< $1`
		local second=`cut -d / -f 2 <<< $1`
		local index=2
		
		local usagestr="[$first"
		[[ $first = $second && ! $first =~ ^-- ]] && local index=1
		if [[ $2 -ne 0 ]]; then
			for i in $(eval echo "{1..$2}"); do
				if [[ -z $4 ]]; then
					local helpstr=$(printf "$helpstr `tr [a-z] [A-Z] <<< ${second:$index}`")
					local usagestr="$usagestr `tr [a-z] [A-Z] <<< ${second:$index}`"
					[[ $2 -ne 1 ]] && local helpstr=$(printf "$helpstr$i") && local usagestr="$usagestr$i"
				else
					local helpstr=$(printf "$helpstr `cut -d , -f $i <<< $4`")
					local usagestr="$usagestr `cut -d , -f $i <<< $4`"
				fi
			done
		fi
		local helpstr=$(printf "$helpstr:\n\t$3")
		local usagestr="$usagestr]"
	else
		[[ $# -ne 2 ]] && error "add_help() requires 2 arguments for positional arguments"
		$ADDED_POSARG_HELP || HELP=$(printf "$HELP\npositional arguments:")
		ADDED_POSARG_HELP=true

		local helpstr=$(printf "\n  $1:\n\t$2")
		local usagestr=$1
	fi
	
	HELP=$(printf "$HELP$helpstr")
	local num=$(( ${#usagestr} + 1 ))
	if (( $USAGE_LEN + $num <= $USAGE_CAP || $USAGE_LEN == 0 )); then
		(( USAGE_LEN = $num ))
		USAGE=$(printf "$USAGE $usagestr")
	else
		local prestring="usage: `basename $0`"
		USAGE=$(printf "$USAGE\\\n")
		for i in $(eval echo "{1..${#prestring}}"); do
			USAGE=$(printf "$USAGE ")
		done
		USAGE=$(printf "$USAGE $usagestr")
		USAGE_LEN=$num
	fi
}

while (( "$#" )); do
    if [[ $1 =~ ^- ]]; then

''' % (name, num, desc) 
	return result

def strargs(args):
	result=""
	if args == "":
		return result
	for arg in args.split(','):
		result+='''        # STR FLAG ====================================================================================
        arg="%s"
		nargs=1
		$BEGIN || add_help $arg $nargs "<insert $arg help here>" #editme
		argval=()
		first=`cut -d / -f 1 <<< $arg`
		second=`cut -d / -f 2 <<< $arg`
		if $BEGIN; then
			if [[ $1 = *"${first:1}" && ! $1 =~ ^-- ]] || [[ ! $second = $first && $1 =~ ^$second ]]; then
				if [[ $nargs -eq 1 ]]; then
					argval+=("`cut -d = -f 2 <<< $1`")
					if [[ ${argval[0]} = $1 ]]; then
						[ -z $2 ] && error $arg "expected one argument"
						SHIFT_NUM=2
						argval[0]=$2
					fi
				else
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && error $arg "expected $nargs arguments"
						argval+=("${@:$i:1}")
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && error $arg "expected $nargs arguments"
				argval+=("`cut -d ${first:1} -f 2 <<< $1`")
				FOUND_FLAG=true
				set -- "`cut -d ${first:1} -f 1 <<< $1`${first:1}" "${@:2}"
				[[ ${argval[0]} = *"h"* && ! "`cut -d ${first:1} -f 1 <<< $1`" = *"h"* ]] && PRINT_HELP=false
			fi
		else
			check_lists $first $second
		fi
		[[ ${#argval[@]} -ne 0 ]] && echo "$arg:${argval[@]}" #editme: store the value of $argval. error-check as needed
		# END =========================================================================================
		
''' % arg
	return result


def intargs(args):
	result=""
	if args == "":
		return result
	for arg in args.split(','):
		result+='''        # INT FLAG ====================================================================================
        arg="%s"
		nargs=1
		$BEGIN || add_help $arg $nargs "<insert $arg help here>" #editme
		argval=""
		first=`cut -d / -f 1 <<< $arg`
		second=`cut -d / -f 2 <<< $arg`
		if $BEGIN; then
			if [[ $1 = *"${first:1}" && ! $1 =~ ^-- ]] || [[ ! $second = $first && $1 =~ ^$second ]]; then
				if [[ $nargs -eq 1 ]]; then
					argval=`cut -d = -f 2 <<< $1`
					if [[ $argval = $1 ]]; then
						[ -z $2 ] && error $arg "expected one argument"
						SHIFT_NUM=2
						argval=$2
					fi
					[[ ! $argval =~ ^[0-9]+$ ]] && error $arg "invalid integer: '$argval'"
				else
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && error $arg "expected $nargs arguments"
						[[ ! ${@:$i:1} =~ ^[0-9]+$ ]] && error $arg "invalid integer: '${@:$i:1}'"
						[[ -z $argval ]] && argval="${@:$i:1}" || argval="$argval ${@:$i:1}"
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && error $arg "expected $nargs arguments"
				argval=`cut -d ${first:1} -f 2 <<< $1`
				[[ ! $argval =~ ^[0-9]+$ ]] && error $arg "invalid integer: '$argval'"
				FOUND_FLAG=true
				set -- "`cut -d ${first:1} -f 1 <<< $1`${first:1}" "${@:2}"
			fi
		else
			check_lists $first $second
		fi
		[[ ! -z $argval ]] && echo $arg:$argval #editme: store the value of $argval. error-check as needed
        # END =========================================================================================
		
''' % (arg)
	return result

def floatargs(args):
	result=""
	if args == "":
		return result
	for arg in args.split(','):
		result+='''        # FLOAT FLAG ==================================================================================
        arg="%s"
		nargs=1
		$BEGIN || add_help $arg $nargs "<insert $arg help here>" #editme
		argval=""
		first=`cut -d / -f 1 <<< $arg`
		second=`cut -d / -f 2 <<< $arg`
		if $BEGIN; then
			if [[ $1 = *"${first:1}" && ! $1 =~ ^-- ]] || [[ ! $second = $first && $1 =~ ^$second ]]; then
				if [[ $nargs -eq 1 ]]; then
					argval=`cut -d = -f 2 <<< $1`
					if [[ $argval = $1 ]]; then
						[ -z $2 ] && error $arg "expected one argument"
						SHIFT_NUM=2
						argval=$2
					fi
					[[ ! $argval =~ ^[0-9]+([.][0-9]+)?$ ]] && error $arg "invalid float: '$argval'"
				else
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && error $arg "expected $nargs arguments"
						[[ ! ${@:$i:1} =~ ^[0-9]+([.][0-9]+)?$ ]] && error $arg "invalid float: '${@:$i:1}'"
						[[ -z $argval ]] && argval="${@:$i:1}" || argval="$argval ${@:$i:1}"
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && error $arg "expected $nargs arguments"
				argval=`cut -d ${first:1} -f 2 <<< $1`
				[[ ! $argval =~ ^[0-9]+([.][0-9]+)?$ ]] && error $arg "invalid float: '$argval'"
				FOUND_FLAG=true
				set -- "`cut -d ${first:1} -f 1 <<< $1`${first:1}" "${@:2}"
			fi
		else
			check_lists $first $second
		fi
		[[ ! -z $argval ]] && echo $arg:$argval #editme: store the value of $argval. error-check as needed
        # END =========================================================================================
		
''' % arg
	return result

def boolargs(args):
	result=""
	if args == "":
		return result
	for arg in args.split(','):
		result+='''        # BOOL FLAG ===================================================================================
        arg="%s"
		$BEGIN || add_help $arg 0 "<insert $arg help here>" #editme
		argval=false
		first=`cut -d / -f 1 <<< $arg`
		second=`cut -d / -f 2 <<< $arg`
		if $BEGIN; then
			if [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]] || [[ $1 = $second ]]; then
				argval=true
				FOUND_FLAG=true
			fi
		else
			check_lists $first $second
		fi
		$argval && echo $arg:$argval #editme: store the value of $argval. error-check as needed
        # END =========================================================================================

''' % arg
	return result

def helparg():
	return '''        # HELP FLAG ===================================================================================
        arg="-h/--help"
		$BEGIN || add_help $arg 0 "print this help message and exit"
        first=`cut -d / -f 1 <<< $arg`
        second=`cut -d / -f 2 <<< $arg`
        if $BEGIN; then
            if [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]] || [[ $1 = $second ]]; then
				FOUND_HELP=true
				PRINT_HELP=true
				FOUND_FLAG=true
            fi
        else
            check_lists $first $second
        fi
        # END =========================================================================================
		
'''

def footer(num):
	result='''		if $BEGIN; then
			[[ $FOUND_FLAG = false ]] && error "unrecognized argument: $1"
			if [[ ${1:0:1} = "-" && ! ${1:0:2} = "--" ]]; then
				while read -n 1 char; do
					[ -z $char ] && continue
					found_char=false
					for w in $FLAG_LIST; do [ $w = $char ] && found_char=true; done
					[[ $found_char = false ]] && error "unrecognized arguments: $1"
				done <<< ${1:1}
			fi
		fi
	else
		$BEGIN && PARAMS="$PARAMS $1"
	fi
	$BEGIN && shift $SHIFT_NUM
	SHIFT_NUM=1
	FOUND_FLAG=false
	FOUND_HELP=false
	BEGIN=true
done
# POSITIONAL ARGUMENTS ==========================================================================

'''
	for i in range(1,num+1):
		result+='''add_help "posarg%i" "<insert posarg%i help here>" #editme
''' % (i, i)
	if num:
		result+="\n"
	
	result+='''# ===============================================================================================
if $PRINT_HELP; then
	echo "$USAGE"
	[[ ! -z $DESC ]] && echo && echo "$DESC"
	echo "$HELP"
	exit 0
fi
for w in $PARAMS; do set -- "$@" "$w"; done
[[ $# -lt $NUM_POS_ARGS ]] && error "too few arguments"
[[ $# -gt $NUM_POS_ARGS ]] && error "too many arguments"

# MAIN SCRIPT ===================================================================================

# ===============================================================================================

'''
	return result

if __name__ == "__main__":
	main()
