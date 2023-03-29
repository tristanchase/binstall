#!/usr/bin/env bash

#-----------------------------------
# Usage Section

#<usage>
#//Usage: binstall [ {-d|--debug} ] [ FILE | {-h|--help} | {-l|--list} | {-u|--update} ]
#//Description: Installs devel scripts into ${HOME}/bin
#//Examples: binstall foo; binstall -d bar; binstall --update
#//Options:
#//	-d --debug	Enable debug mode
#//	-h --help	Display this help message
#//	-l --list	List installed scripts
#//	-u --update	Update installed scripts
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
#_listfile="${HOME}/tmp/binstall.$$.tempfile"

# List of temp files to clean up on exit (put last)
#_tempfiles=("${_listfile}")

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
function __compare_dirs__ {
	_bin_dir="${HOME}/bin"
	_devel_dir="${HOME}/devel"

	_bin_list=( $(stat -c "'%n'" "${_bin_dir}"/* | xargs basename -a) )

	_devel_list=(
		$(for _item in "${_bin_list[@]}"; do
			stat -c "'%n'" "${_devel_dir}"/"${_item}"/"${_item}".sh 2>/dev/null | xargs basename -a 2>/dev/null
		done)
	)
}

function __get_bin_time_reg__ {
	stat -c "%y" "${_bin_dir}"/"${_filename%.sh}"
}

function __get_bin_time_epoch__ {
	stat -c "%Y" "${_bin_dir}"/"${_filename%.sh}"
}

function __get_col_widths__ {
	_max_filename_length=$(printf "%s\n" "${_devel_list[@]}" | wc -L)
	_devel_time_col_width=$(__get_devel_time_reg__ | wc -L)
	_bin_time_col_width=$(__get_bin_time_reg__ | wc -L)
}

function __get_devel_time_reg__ {
	stat -c "%y" "${_devel_dir}"/"${_filename%.sh}"/"${_filename}"
}

function __get_devel_time_epoch__ {
	stat -c "%Y" "${_devel_dir}"/"${_filename%.sh}"/"${_filename}"
}

function __list_files__ {
	__compare_dirs__
	__get_col_widths__
	_column_format="%-"${_max_filename_length}"s | %-"${_devel_time_col_width}"s | %-"${_bin_time_col_width}"s\n"
	_listfile="${HOME}/tmp/binstall.$$.tempfile"
	touch "${_listfile}"

	printf "${_column_format}" "filename" "devel time" "bin time" > "${_listfile}"
	__separator__ >> "${_listfile}"
	for _filename in "${_devel_list[@]}"; do
		if [[ "$(__get_devel_time_epoch__)" -gt "$(__get_bin_time_epoch__)" ]]; then
			printf ""${fg_red}"${_column_format}"${reset}"" "${_filename}" "$(__get_devel_time_reg__)" "$(__get_bin_time_reg__)"
		else
			printf "${_column_format}" "${_filename}" "$(__get_devel_time_reg__)" "$(__get_bin_time_reg__)"
		fi

	done >> "${_listfile}"

	cat "${_listfile}" | more

	_tempfiles=("${_listfile}")
	__local_cleanup__
	unset _tempfiles

	exit 0
}

function __local_cleanup__ {
	if [[ -n "${_tempfiles:-}" ]]; then
		rm "$(printf "%b\n" "${_tempfiles:-}")"
	fi
}

function __separator__ {
	function __col_1__ {
	       	_col_1=$(printf "%*s" "${_max_filename_length}")
	       	_col_1=${_col_1// /=}
		printf "%b\n" "${_col_1}"
       	}
	function __col_2__ {
	       	_col_2=$(printf "%*s" "${_devel_time_col_width}")
	       	_col_2=${_col_2// /=}
		printf "%b\n" "${_col_2}"
       	}
	function __col_3__ {
	       	_col_3=$(printf "%*s" "${_bin_time_col_width}")
	       	_col_3=${_col_3// /=}
		printf "%b\n" "${_col_3}"
       	}
	printf "%s | %s | %s\n" "$(__col_1__)" "$(__col_2__)" "$(__col_3__)"

}

function __update__ {
	__compare_dirs__
	_update_list=(
		$(for _filename in "${_devel_list[@]}"; do
		if [[ "$(__get_devel_time_epoch__)" -gt "$(__get_bin_time_epoch__)" ]]; then
			printf "%s\n" "${_filename}"
		fi
		done)
	)

	if [[ -z "${_update_list[@]}" ]]; then
		exit 0
	fi

	printf "%b\n" "The following "${#_update_list[@]}" files can be updated in your ~/bin:"
	printf "%s\n" "${_update_list[@]}"
	printf "%b" "Would you like to update them (y/N)? "
	read _update_yN

	if [[ "${_update_yN}" =~ (y|Y) ]]; then
		for _file in "${_update_list[@]}"; do
			binstall "${_file}"
		done
	fi
	exit 0
}

#</functions>

#-----------------------------------
# Source helper functions
for _helper_file in functions colors git-prompt; do
	if [[ ! -e ${HOME}/."${_helper_file}".sh ]]; then
		printf "%b\n" "Downloading missing script file "${_helper_file}".sh..."
		sleep 1
		wget -nv -P ${HOME} https://raw.githubusercontent.com/tristanchase/dotfiles/main/"${_helper_file}".sh
		mv ${HOME}/"${_helper_file}".sh ${HOME}/."${_helper_file}".sh
	fi
done

source ${HOME}/.functions.sh

#-----------------------------------
# Get some basic options
# TODO Make this more robust
#<options>
shopt -s extglob
case "${1:-}" in
	(-d|--debug) __debugger__ ;;
	(-h|--help) __usage__ ;;
	(-u|--update) __update__ ;;
	(-l|--list) __list_files__ ;;
	(-*|--*) printf "%b\n" "Option \""${1:-}"\" not recognized." ; __usage__ ;;
	(*) _name="${1:-}"
esac
shopt -u extglob
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
