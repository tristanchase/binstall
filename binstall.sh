#!/usr/bin/env bash

# Low-tech debug mode
if [[ "${1:-}" =~ (-d|--debug) ]]; then
	set -x
	exec > >(tee ""${HOME}"/tmp/$(basename "${0}")-debug.$$") 2>&1
	shift
fi

# Same as set -euE -o pipefail
set -o errexit
set -o nounset
set -o errtrace
set -o pipefail
IFS=$'\n\t'

#-----------------------------------

#//Usage: binstall [ {-d|--debug} ] [ FILE | {-h|--help} ]
#//Description: Installs devel scripts into ${HOME}/bin
#//Examples: binstall foo; binstall -d bar
#//Options:
#//	-d --debug	Enable debug mode
#//	-h --help	Display this help message

# Created: 2020-04-08T03:06:44-04:00
# Tristan M. Chase <tristan.m.chase@gmail.com>

# Depends on:
#   rsync

#-----------------------------------
# Low-tech help option

function __usage() { grep '^#//' "${0}" | cut -c4- ; exit 0 ; }
expr "$*" : ".*-h\|--help" > /dev/null && __usage

#-----------------------------------
# Low-tech logging function

readonly LOG_FILE=""${HOME}"/tmp/$(basename "${0}").log"
function __info()    { echo "[INFO]    $*" | tee -a "${LOG_FILE}" >&2 ; }
function __warning() { echo "[WARNING] $*" | tee -a "${LOG_FILE}" >&2 ; }
function __error()   { echo "[ERROR]   $*" | tee -a "${LOG_FILE}" >&2 ; }
function __fatal()   { echo "[FATAL]   $*" | tee -a "${LOG_FILE}" >&2 ; exit 1 ; }

#-----------------------------------
# Trap functions

function __traperr() {
	__info "ERROR: ${FUNCNAME[1]}: ${BASH_COMMAND}: $?: ${BASH_SOURCE[1]}.$$ at line ${BASH_LINENO[0]}"
}

function __ctrl_c(){
	exit 2
}

function __cleanup() {
	case "$?" in
		0) # exit 0; success!
			#do nothing
			;;
		2) # exit 2; user termination
			__info ""$(basename $0).$$": script terminated by user."
			;;
		3) # exit 3; file not found
			echo "File \""${_name}"\" not found in your devel scripts."
			;;
		9) # exit 9; exit test
			__info ""$(basename $0).$$": ${FUNCNAME[1]} test: ok."
			;;
		*) # any other exit number; indicates an error in the script
			#clean up stray files
			#__fatal ""$(basename $0).$$": [error message here]"
			;;
	esac
}

#-----------------------------------
# Main Script Wrapper

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
	trap __traperr ERR
	trap __ctrl_c INT
	trap __cleanup EXIT
#-----------------------------------
# Main Script goes here
_name="${1:-}"


# If _arg_1 is empty, ask for filename else exit
if [[ -z "${1:-}" ]]; then
	printf "Enter the name of the script you would like to install (blank quits): "
	read _name
	if [[ -z ${_name:-} ]]; then
		exit 2
	fi
fi

# Handle if _arg_1=filename.sh (strips off .sh)
_name="${_name%.sh}"

# Exit if file does not exist
_finder="$(find "${HOME}"/devel -iname "${_name}".sh)"
if [[ -z "${_finder}" ]]; then
	exit 3 # file not found
fi

_devel_dir="${HOME}/devel/${_name}"
_sh_file="${_devel_dir}/${_name}.sh"
_bin_dir="${HOME}/bin"
_bin_file="${_bin_dir}/${_name}"


function __do_install(){
	rsync --update "${_sh_file}" "${_bin_file}"
	chmod 755 "${_bin_file}"
}

__do_install

# Main Script ends here
#-----------------------------------

fi

# End of Main Script Wrapper
#-----------------------------------

exit 0

# TODO
#
