#!/usr/bin/env bash
set -euo pipefail
set -o errtrace
set -x
IFS=$'\n\t'

#-----------------------------------

#/ Usage: binstall { FILE | --help }
#/ Description: Installs devel scripts into ${HOME}/bin
#/ Examples: binstall loco
#/ Options:
#/   --help: Display this help message

# Created: 2020-04-08T03:06:44-04:00
# Tristan M. Chase <tristan.m.chase@gmail.com>

# Depends on:
#   rsync

#-----------------------------------
# Low-tech help option

function __usage() { grep '^#/' "${0}" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

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
		3) # exit 2; user termination
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

# * If _arg_1 is empty, ask for filename else exit
function __arg_1_empty(){
		printf "Enter the name of the script you would like to install (blank quits): "
		read _name
		if [[ -z ${_name:-} ]]; then
			exit 2
		fi
		__do_install
}

_devel_dir="${HOME}/devel/${_name}"
_sh_file="${_devel_dir}/${_name}.sh"
_bin_dir="${HOME}/bin"
_bin_file="${_bin_dir}/${_name}"

# TODO Handle if _arg_1=filename.sh
	#__arg_1_has_dot_sh
# TODO Handle arg _arg_1 does not exist
	#__arg_1_not_exists

function __do_install(){
	rsync --update "${HOME}"/devel/"${_name:-}"/"${_name:-}".sh "${HOME}"/bin/"${_name:-}"
	#rsync --update "${HOME}"/devel/"${1:-}"/"${1:-}".sh "${HOME}"/bin/"${1:-}"
	
}

# Runtime
if [[ -z "${1:-}" ]]; then
	__arg_1_empty
# elif Handle if _arg_1=filename.sh
	#__arg_1_has_dot_sh
# elif Handle arg _arg_1 does not exist
	#__arg_1_not_exists
elif [[ "${1:-}" =~ (-h|--help) ]]; then
	__usage
else
	__do_install
fi
# End runtime

# Main Script ends here
#-----------------------------------

fi

# End of Main Script Wrapper
#-----------------------------------

exit 0

# TODO
#
# * Update dependencies section
# * Update usage, description, and options section
# + If _arg_1 is empty, ask for filename else exit
