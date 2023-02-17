#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

function echo_stderr()
{
	>&2 echo ${@}
}

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

if [[ "$(git rev-parse --symbolic --abbrev-ref HEAD)" == "master" ]]; then
	echo_stderr "Attempting to commit to branch [$(git rev-parse --symbolic --abbrev-ref HEAD)]"
	exit 1
fi

function find_cmd()
{
	cmd="$1"
	if [[ -z "${cmd}" ]]; then
		echo_stderr "No command supplied!"
		echo 0
		return
	fi

	if [[ $(command -v ${cmd}) ]]; then
		echo 1
	else
		echo 0
	fi
}

function check_disabled()
{
	check_name=$1
	if [[ -z "${check_name}" ]]; then
		echo_stderr "No check supplied!"
		echo 0
		return
	fi

	check_var="DISABLE_$(echo ${check_name} | tr '[:lower:]' '[:upper:]')"
	check_var_val="$(eval "echo \${${check_var}}")"

	if [[ "${check_var_val}" -eq 1 || "${check_var_val}" =~ ^[yY]([eE][sS])?$ ]]; then
		echo 1
	else
		echo 0
	fi
}

function ret_array()
{
	declare -a arr=${@}

	for idx in $(seq 0 $[ ${#arr[@]} - 1 ]); do
		echo "${arr[$idx]}"
	done
}

function is_test_file()
{
	file_name=$1
	if [[ -z "${file_name}" ]]; then
		echo_stderr "No file supplied!"
		echo 0
		return
	fi

	if [[ -n $(echo ${file_name%/*} | grep -E "(^|/)test[s]?($|/)" ) || -d "${file_name%/*}" ]]; then
		echo 1
	else
		echo 0
	fi
}

function clang_format_check()
{
	if [[ $(check_disabled clang_format) -eq 1 ]]; then
		echo_stderr "clang_format check disabled"
		return
	fi
	declare -a staged_files=${@}
	declare -a check_errors
	cmd_found=$(find_cmd clang-format)

	for staged_file in ${staged_files[@]}; do
		if [[ -z $(echo ${staged_file} | grep -iE ".*\.(c|cpp|h|hpp)$") ]]; then
			continue
		fi
		if [[ ${cmd_found} -eq 0 ]]; then
			check_errors=("${check_errors[@]}" "File failed clang-format check [${staged_file}][missing clang-format executable]")
			continue
		fi

		RES="$(clang-format --style=file --dry-run -Werror --ferror-limit=0 ${staged_file} 2>&1)"
		if [[ $? -ne 0 ]] ; then
			check_errors=("${check_errors[@]}" "File failed clang-format check [${staged_file}].")
		fi
	done

	ret_array ${check_errors[@]}
}

function radon_check()
{
	if [[ $(check_disabled radon) -eq 1 ]]; then
		echo_stderr "radon check disabled"
		return
	fi
	declare -a staged_files=${@}
	declare -a check_errors
	cmd_found=$(find_cmd radon)

	for staged_file in ${staged_files[@]}; do
		if [[ -z $(echo ${staged_file} | grep -iE ".*\.(py)$") || $(is_test_file ${staged_file}) -eq 1 ]]; then
			continue
		fi

		if [[ ${cmd_found} -eq 0 ]]; then
			check_errors=("${check_errors[@]}" "File failed radon check [${staged_file}][missing radon executable]")
			continue
		fi

		file_check="$(radon cc --min C ${staged_file} | tail +2 | tr "\n" " " | sed -e 's/^ *//' -e 's/ \{2,\}/, /g' -e 's/ *$//')"
		if [[ -n "${file_check}" ]] ; then
			check_errors=("${check_errors[@]}" "File failed radon check [${staged_file}][${file_check%,}]")
		fi
	done

	ret_array ${check_errors[@]}
}

function mypy_check()
{
	if [[ $(check_disabled mypy) -eq 1 ]]; then
		echo_stderr "mypy check disabled"
		return
	fi
	declare -a staged_files=${@}
	declare -a check_errors
	cmd_found=$(find_cmd mypy)

	for staged_file in ${staged_files[@]}; do
		if [[ -z $(echo ${staged_file} | grep -iE ".*\.(py)$") ]]; then
			continue
		fi
		if [[ ${cmd_found} -eq 0 ]]; then
			check_errors=("${check_errors[@]}" "File failed mypy check [${staged_file}][missing mypy executable]")
			continue
		fi

		file_check="$(mypy --follow-imports=silent --ignore-missing-imports ${staged_file} | sed '$d' | sed -e 's/^[^ :]*:[0-9]*: *//' | tr "\n" ",")"
		if [[ -n "${file_check}" ]] ; then
			check_errors=("${check_errors[@]}" "File failed mypy check [${staged_file}][${file_check%,}]")
		fi
	done

	ret_array ${check_errors[@]}
}

function symbolic_links_check()
{
	if [[ $(check_disabled symbolic_links) -eq 1 ]]; then
		echo_stderr "symbolic_links check disabled"
		return
	fi
	declare -a staged_files=${@}
	declare -a check_errors

	for staged_file in ${staged_files[@]}; do
		if [[ -L "${staged_file}" ]]; then
			check_errors=("${check_errors[@]}" "Attempting to commit a symbolic link [${staged_file}]")
		fi
	done

	ret_array ${check_errors[@]}
}

declare -a INVALID_STRINGS=(
	'# DEBUG.*$'
	'// DEBUG.*$'
	'# DEV MARKER.*$'
	'// DEV MARKER.*$'
)
declare -a ERRORS_ARRAY

OLD_IFS=${IFS}
IFS=$'\n'
declare -a MODIFIED_FILES=$(git diff --staged --name-status | grep -vE "^D" | sed -e 's/[ACMRT][[:space:]]*//')

ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" $(symbolic_links_check ${MODIFIED_FILES}))

# DEBUG messages
for staged_file in ${MODIFIED_FILES[@]}; do
	for invalid_string in "${INVALID_STRINGS[@]}"; do
		if [[ -n "$(git diff ${against} "${staged_file}" | grep -E "^\+.*${invalid_string}")" ]]; then
			ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" "Attempting to commit a DEBUG message [${staged_file}].")
		fi
	done
done

for staged_file in ${MODIFIED_FILES[@]}; do
	# Don't commit files with non LF line endings.
	staged_file_line_ending="$(file ${staged_file} | grep -Eo 'with [^ ]+ line terminators')"
	if [ -n "${staged_file_line_ending}" ]; then
		ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" "Attempting to commit a file ${staged_file_line_ending} [${staged_file}].")
	fi
done

# clang-format check
ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" $(clang_format_check ${MODIFIED_FILES}))

# radon check
ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" $(radon_check ${MODIFIED_FILES}))

# mypy check
#ERRORS_ARRAY=("${ERRORS_ARRAY[@]}" $(mypy_check ${MODIFIED_FILES}))


IFS=${OLD_IFS}


if [ ${#ERRORS_ARRAY[@]} -gt 0 ]; then
	for idx in $(seq 0 $[ ${#ERRORS_ARRAY[@]} - 1 ]); do
		echo "${ERRORS_ARRAY[$idx]}"
	done
	echo_stderr "Aborting."
	exit 1
fi

# If you want to allow non-ascii filenames set this variable to true.
allownonascii=$(git config hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ascii filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
	# Note that the use of brackets around a tr range is ok here, (it's
	# even required, for portability to Solaris 10's /usr/bin/tr), since
	# the square bracket bytes happen to fall in the designated range.
	test $(git diff --cached --name-only --diff-filter=A -z $against |
	  LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0
then
	echo "Error: Attempt to add a non-ascii file name."
	echo
	echo "This can cause problems if you want to work"
	echo "with people on other platforms."
	echo
	echo "To be portable it is advisable to rename the file ..."
	echo
	echo "If you know what you are doing you can disable this"
	echo "check using:"
	echo
	echo "  git config hooks.allownonascii true"
	echo
	exit 1
fi

# If there are whitespace errors, print the offending file names and fail.
exec git diff-index --check --cached $against --

