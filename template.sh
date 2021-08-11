#!/bin/bash
#Bash Argument Parser (BAP) v1.5.5
USAGE="usage: `basename $0`"
PREUSAGE=${#USAGE}
USAGE_LEN=0
DESC_LEN=0
HELP_LEN=0
LINE_CAP=50
HELP=""
PARAMS=""
FLAG_LIST=""
LONG_FLAG_LIST=""
REQ_ARG_LIST=""
GIVEN_REQ_ARG_LIST=""
SHIFT_NUM=1
ADDED_FLAG_HELP=false
ADDED_POSARG_HELP=false
FOUND_FLAG=false
PRINT_HELP=false
PRINT_VERSION=false
BEGIN=false

# SCRIPT OPTIONS ================================================================================
NUM_POS_ARGS=0 #editme
DESC="" #editme
VERSION="" #editme
# ===============================================================================================

# SCRIPT VARIABLES ==============================================================================

# ===============================================================================================

function die { echo "$USAGE"; echo $@ >&2; exit 1; }
function error {
	[[ $# -eq 0 ]] && die "error"
	[[ $# -eq 1 ]] && die "error: $1"
	die "error: argument $1: $2"
}
function format_desc {
	local descstring=$DESC
	DESC=""
	for word in $descstring; do
		local num=${#word}
		if (( $DESC_LEN + $num + 1 > $LINE_CAP || $DESC_LEN == 0 )); then
			DESC=$(printf "$DESC\n$word")
			(( DESC_LEN = $num ))
		else
			DESC=$(printf "$DESC $word")
			(( DESC_LEN += $num + 1 ))
		fi
	done
	echo "$DESC"
}
function check_lists { 
	[[ $# -ne 2 ]] && error "check_lists() requires 2 arguments"
	first=`cut -d / -f 1 <<< $1`
	second=`cut -d / -f 2 <<< $1`
	if [[ ! $first =~ ^-- ]]; then
		[[ $FLAG_LIST = *"${first:1}"* ]] && error "duplicate flag $first"
		FLAG_LIST="${first:1} $FLAG_LIST"
	fi
	if [[ $second =~ ^-- ]]; then
		[[ $LONG_FLAG_LIST = *"$second"* ]] && error "duplicate long flag $second"
		LONG_FLAG_LIST="$second $LONG_FLAG_LIST"
	fi
	if $2; then REQ_ARG_LIST="$1 $REQ_ARG_LIST"; fi
}
function add_help {
	[[ -z $1 ]] && error "add_help() requires 4-5 arguments for flags, 2 arguments for positional arguments"
	
	if [[ ${1:0:1} = "-" ]]; then
		[[ $# -lt 4 || $# -gt 5 ]] && error "add_help() requires 4-5 arguments for flags"
		$ADDED_FLAG_HELP || HELP=$(printf "$HELP\noptional arguments:")
		ADDED_FLAG_HELP=true
		
		local helpstr=$(printf "\n  $1")
		local first=`cut -d / -f 1 <<< $1`
		local second=`cut -d / -f 2 <<< $1`
		local index=2
		
		$3 || local usagestr="["
		local usagestr="$usagestr$first"
		[[ $first = $second && ! $first =~ ^-- ]] && local index=1
		if [[ $2 -ne 0 ]]; then
			for i in $(eval echo "{1..$2}"); do
				if [[ -z $5 ]]; then
					local helpstr=$(printf "$helpstr `tr [a-z] [A-Z] <<< ${second:$index}`")
					local usagestr="$usagestr `tr [a-z] [A-Z] <<< ${second:$index}`"
					[[ $2 -ne 1 ]] && local helpstr=$(printf "$helpstr$i") && local usagestr="$usagestr$i"
				else
					local helpstr=$(printf "$helpstr `cut -d , -f $i <<< $5`")
					local usagestr="$usagestr `cut -d , -f $i <<< $5`"
				fi
			done
		fi
		local helpstr=$(printf "$helpstr:\n\t")
		HELP_LEN=0
		for word in $4; do
			local num=${#word}
			if (( $HELP_LEN + $num + 4 <= $LINE_CAP )); then
				if (( $HELP_LEN == 0 )); then
					local helpstr=$(printf "$helpstr$word")
					HELP_LEN=$num
				else
					local helpstr=$(printf "$helpstr $word")
					(( HELP_LEN += $num + 1 ))
				fi
			else
				local helpstr=$(printf "$helpstr\n\t$word")
				HELP_LEN=$num
			fi
		done
		$3 || local usagestr="$usagestr]"
	else
		[[ $# -ne 2 ]] && error "add_help() requires 2 arguments for positional arguments"
		$ADDED_POSARG_HELP || HELP=$(printf "$HELP\npositional arguments:")
		ADDED_POSARG_HELP=true

		local helpstr=$(printf "\n  $1:\n\t")
		HELP_LEN=0
		for word in $2; do
			local num=${#word}
			if (( $HELP_LEN + $num + 8 <= $LINE_CAP )); then
				if (( $HELP_LEN == 0 )); then
					local helpstr=$(printf "$helpstr$word")
					HELP_LEN=$num
				else
					local helpstr=$(printf "$helpstr $word")
					(( HELP_LEN = $num + 1 ))
				fi
			else
				local helpstr=$(printf "$helpstr\n\t$word")
				HELP_LEN=$num
			fi
		done
		local usagestr=$1
	fi
	
	HELP=$(printf "$HELP$helpstr")
	local num=$(( ${#usagestr} + 1 ))
	if (( $PREUSAGE + $USAGE_LEN + $num <= $LINE_CAP || $USAGE_LEN == 0 )); then
		(( USAGE_LEN += $num ))
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
	BEGIN=true
done
# POSITIONAL ARGUMENTS ==========================================================================

# ===============================================================================================
if $PRINT_HELP; then
	echo "$USAGE"
	[[ ! -z $DESC ]] && echo "$(format_desc)"
	echo "$HELP"
	exit 0
fi
if $PRINT_VERSION; then
	[[ -z $VERSION ]] && error "version string is empty"
	echo $VERSION
	exit 0
fi
for req in $REQ_ARG_LIST; do [[ $GIVEN_REQ_ARG_LIST = *"$req"* ]] || error $req "argument is required"; done
for w in $PARAMS; do set -- "$@" "$w"; done
[[ $# -lt $NUM_POS_ARGS ]] && error "too few arguments"
[[ $# -gt $NUM_POS_ARGS ]] && error "too many arguments"

# MAIN SCRIPT ===================================================================================

# ===============================================================================================
