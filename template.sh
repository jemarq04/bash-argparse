#!/bin/bash
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

# SCRIPT OPTIONS ================================================================================
NUM_POS_ARGS=0 #editme
DESC=$(printf "") #editme
# ===============================================================================================

# SCRIPT VARIABLES ==============================================================================

# ===============================================================================================

function die { echo "$USAGE"; echo $@ >&2; exit 1; }
function error {
	[[ $# -eq 0 ]] && die "error"
	[[ $# -eq 1 ]] && die "error: $1"
	die "error: argument $1: $2"
}
function check_lists { 
	[[ $# -ne 2 ]] && error "check_lists() requires 2 arguments"
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
		
		if $BEGIN; then
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

# ===============================================================================================
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
