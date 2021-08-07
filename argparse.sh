#!/bin/bash
USAGE=""
HELP=""
PARAMS=""
FLAG_LIST=""
LONG_FLAG_LIST=""
SHIFT_NUM=1
FOUND_FLAG=false
FOUND_HELP=false
PRINT_HELP=false
BEGIN=false

#TODO: Add 'metavar' support for add_help()

# SCRIPT OPTIONS ================================================================================
NUM_POS_ARGS=1
DESC=$(printf "")
function usage { echo "usage: `basename $0` [optional-args] required-args"; }
# ===============================================================================================

# SCRIPT VARIABLES ==============================================================================

# ===============================================================================================

function die { echo $(usage); echo error: $@ >&2; exit 1; }
function check_lists { 
	[[ $# -ne 2 ]] && die "script error: check_lists() requires two arguments"
	if [[ ! $1 =~ ^-- ]]; then
		[[ $FLAG_LIST = *"${1:1}"* ]] && die "script error: duplicate flag $1"
		FLAG_LIST="${1:1} $FLAG_LIST"
	fi
	if [[ ${2:0:2} = "--" ]]; then
		[[ $LONG_FLAG_LIST = *"$2"* ]] && die "script error: duplicate long flag $2"
		LONG_FLAG_LIST="$2 $LONG_FLAG_LIST"
	fi
}
function add_help {
	[[ $# -ne 3 ]] && die "script error: add_help() requires three arguments"
	local helpstr=$(printf "\n  $1")
	local first=`cut -d / -f 1 <<< $1`
	local second=`cut -d / -f 2 <<< $1`
	local index=2

	[[ $first = $second && ! $first =~ ^-- ]] && local index=1
	if [[ $2 -ne 0 ]]; then
		
		for i in $(eval echo "{1..$2}"); do
			local helpstr=$(printf "$helpstr `tr [a-z] [A-Z] <<< ${second:$index}`")
			[[ $2 -ne 1 ]] && local helpstr=$(printf "$helpstr$i")
		done
	fi

	local helpstr=$(printf "$helpstr:\n\t$3")

	HELP=$(printf "$HELP$helpstr")
}

HELP=$(printf "\noptional arguments:")
while (( "$#" )); do
	if [[ $1 =~ ^- ]]; then
		
		# HELP FLAG ===================================================================================
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
		
		# STR FLAG ====================================================================================
		arg="-s/--str"
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
						[ -z $2 ] && die "argument $arg: expected one argument"
						SHIFT_NUM=2
						argval[0]=$2
					fi
				else
					die "script error: not implimented yet"
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && die "argument $arg: expected $nargs arguments"
						argval+=("${@:$i:1}")
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && die "argument $arg: expected $nargs arguments"
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
		
		# INT FLAG ====================================================================================
		arg="-n/--num"
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
						[ -z $2 ] && die "argument $arg: expected one argument"
						SHIFT_NUM=2
						argval=$2
					fi
					[[ ! $argval =~ ^[0-9]+$ ]] && die "argument $arg: invalid integer: '$argval'"
				else
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && die "argument $arg: expected $nargs arguments"
						[[ ! ${@:$i:1} =~ ^[0-9]+$ ]] && die "argument $arg: invalid integer: '${@:$i:1}'"
						[[ -z $argval ]] && argval="${@:$i:1}" || argval="$argval ${@:$i:1}"
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && die "argument $arg: expected $nargs arguments"
				argval=`cut -d ${first:1} -f 2 <<< $1`
				[[ ! $argval =~ ^[0-9]+$ ]] && die "argument $arg: invalid integer: '$argval'"
				FOUND_FLAG=true
				set -- "`cut -d ${first:1} -f 1 <<< $1`${first:1}" "${@:2}"
			fi
		else
			check_lists $first $second
		fi
		[[ ! -z $argval ]] && echo $arg:$argval #editme: store the value of $argval. error-check as needed
		# END =========================================================================================

		# FLOAT FLAG ==================================================================================
		arg="-f/--float"
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
						[ -z $2 ] && die "argument $arg: expected one argument"
						SHIFT_NUM=2
						argval=$2
					fi
					[[ ! $argval =~ ^[0-9]+([.][0-9]+)?$ ]] && die "argument $arg: invalid float: '$argval'"
				else
					(( end = $nargs + 1 ))
					for i in $(eval echo "{2..$end}"); do
						[[ -z ${@:$i:1} ]] && die "argument $arg: expected $nargs arguments"
						[[ ! ${@:$i:1} =~ ^[0-9]+([.][0-9]+)?$ ]] && die "argument $arg: invalid float: '${@:$i:1}'"
						[[ -z $argval ]] && argval="${@:$i:1}" || argval="$argval ${@:$i:1}"
					done
					(( SHIFT_NUM = $nargs + 1 ))
				fi
				FOUND_FLAG=true
			elif [[ $1 = *"${first:1}"* && ! $1 =~ ^-- ]]; then
				[[ $nargs -ne 1 ]] && die "argument $arg: expected $nargs arguments"
				argval=`cut -d ${first:1} -f 2 <<< $1`
				[[ ! $argval =~ ^[0-9]+([.][0-9]+)?$ ]] && die "argument $arg: invalid float: '$argval'"
				FOUND_FLAG=true
				set -- "`cut -d ${first:1} -f 1 <<< $1`${first:1}" "${@:2}"
			fi
		else
			check_lists $first $second
		fi
		[[ ! -z $argval ]] && echo $arg:$argval #editme: store the value of $argval. error-check as needed
		# END =========================================================================================
		
		# BOOL FLAG ===================================================================================
		arg="-a"
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
		
		if $BEGIN; then
			[[ $FOUND_FLAG = false ]] && die "unrecognized argument: $1"
			if [[ ${1:0:1} = "-" && ! ${1:0:2} = "--" ]]; then
				while read -n 1 char; do
					[ -z $char ] && continue
					found_char=false
					for w in $FLAG_LIST; do [ $w = $char ] && found_char=true; done
					[[ $found_char = false ]] && die "unrecognized arguments: $1"
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
HELP=$(printf "$HELP\n\npositional arguments:")
HELP=$(printf "$HELP\n  posarg1:\n\t<insert posarg1 help here>") #editme
if $PRINT_HELP; then
	echo $(usage)
	[[ ! -z $DESC ]] && echo && echo "$DESC"
	echo "$HELP"
	exit 0
fi
for w in $PARAMS; do set -- "$@" "$w"; done
[[ $# -lt $NUM_POS_ARGS ]] && die "too few arguments"
[[ $# -gt $NUM_POS_ARGS ]] && die "too many arguments"
unset -f usage
unset -f check_lists

# MAIN SCRIPT ===================================================================================

echo
echo Flag list: $FLAG_LIST
echo Long Flag List: $LONG_FLAG_LIST
echo We are left with: $@

# ===============================================================================================

unset -f die
