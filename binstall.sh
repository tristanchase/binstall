#!/usr/bin/env bash

#-----------------------------------
# Usage Section

#<usage>
#//Usage: binstall [ {-d|--debug} ] [ FILE | {-h|--help} ]
#//Description: Installs devel scripts into ${HOME}/bin
#//Examples: binstall foo; binstall -d bar
#//Options:
#//	-d --debug	Enable debug mode
#//	-h --help	Display this help message
#</usage>

#<created>
# Created: 2020-04-08T03:06:44-04:00
# Tristan M. Chase <tristan.m.chase@gmail.com>
#</created>

#<depends>
# Depends on:
#   rsync
#</depends>

#-----------------------------------
# TODO Section

#<todo>
# TODO

# DONE
# + Insert script
# + Clean up stray ;'s
# + Modify command substitution to "$(this_style)"
# + Rename function_name() to function __function_name__ /\w+\(\)
# + Rename $variables to "${_variables}" /\$\w+/s+1 @v vEl,{n
# + Check that _variable="variable definition" (make sure it's in quotes)
# + Update usage, description, and options section
# + Update dependencies section

#</todo>

#-----------------------------------
# License Section

#<license>
# Put license here
#</license>

#-----------------------------------
# Runtime Section

#<main>
# Initialize variables
#_temp="file.$$"

# List of temp files to clean up on exit (put last)
#_tempfiles=("${_temp}")

# Put main script here
function __main_script__ {

#_name="${1:-}"


# If _arg_1 is empty, ask for filename else exit
if [[ -z "${_name:-}" ]]; then
	printf "Enter the name of the script you would like to install (blank quits): "
	read _name
	if [[ -z "${_name:-}" ]]; then
		exit 2
	fi
fi

# Handle if _arg_1=filename.sh (strips off .sh)
_name="${_name%.sh}"

# Exit if file does not exist
_finder="$(find ${HOME}/devel -iname "${_name}".sh)"
if [[ -z "${_finder}" ]]; then
	printf "%b\n" "File \""${_name}".sh\" not found in directory ~/devel/"${_name}"."
	exit 3 # file not found
fi

_devel_dir="${HOME}/devel/${_name}"
_sh_file="${_devel_dir}/${_name}.sh"
_bin_dir="${HOME}/bin"
_bin_file="${_bin_dir}/${_name}"


function __do_install__ {
	rsync --update "${_sh_file}" "${_bin_file}"
	chmod 755 "${_bin_file}"
}

__do_install__


} #end __main_script__
#</main>

#-----------------------------------
# Local functions

#<functions>
function __local_cleanup__ {
	:
}
#</functions>

#-----------------------------------
# Source helper functions
for _helper_file in functions colors git-prompt; do
	if [[ ! -e ${HOME}/."${_helper_file}".sh ]]; then
		printf "%b\n" "Downloading missing script file "${_helper_file}".sh..."
		sleep 1
		wget -nv -P ${HOME} https://raw.githubusercontent.com/tristanchase/dotfiles/master/"${_helper_file}".sh
		mv ${HOME}/"${_helper_file}".sh ${HOME}/."${_helper_file}".sh
	fi
done

source ${HOME}/.functions.sh

#-----------------------------------
# Get some basic options
# TODO Make this more robust
#<options>
if [[ "${1:-}" =~ (-d|--debug) ]]; then
	__debugger__
elif [[ "${1:-}" =~ (-h|--help) ]]; then
	__usage__
else
	_name="${1:-}"
fi
#</options>

#-----------------------------------
# Bash settings
# Same as set -euE -o pipefail
#<settings>
set -o errexit
set -o nounset
set -o errtrace
set -o pipefail
IFS=$'\n\t'
#</settings>

#-----------------------------------
# Main Script Wrapper
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
	trap __traperr__ ERR
	trap __ctrl_c__ INT
	trap __cleanup__ EXIT

	__main_script__


fi

exit 0
