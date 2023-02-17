#!/bin/bash

# TODO - Add header

BASEDIR=$(dirname "$0")
DRY_RUN=true
PLATFORM=''

case "${OSTYPE}" in
'linux'*)
    PLATFORM='linux'
    ;;
'darwin'*)
    PLATFORM='darwin'
    ;;
*)
    echo "Unsupported OS type [${OSTYPE}]"
    exit 1
    ;;
esac

# Colors for pretty printing stuff.
NC='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

function __echo_color() {
    color="${1}"
    shift
    echo -e "${color}${@}\033[0m"
}

function echo_header() {
    __echo_color "${WHITE}===== ${@} ====="
}

function echo_error() {
    __echo_color ${RED} ${@}
}

function echo_warning() {
    __echo_color ${YELLOW} ${@}
}

function echo_info() {
    __echo_color ${NC} ${@}
}

function get_value_for_platform() {
    linux_value="${1}"
    darwin_value="${2}"

    if [[ ${PLATFORM} == 'linux' ]]; then
        echo "${linux_value}"
    elif [[ ${PLATFORM} == 'darwin' ]]; then
        echo "${darwin_value}"
    else
        echo_error "I don't know how this happened [OSTYPE:${OSTYPE}][PLATFORM:${PLATFORM}]"
        exit 1
    fi
}

function run_cmd() {
    if ${DRY_RUN}; then
        echo_info "Would execute command [${@}]"
        return 0
    fi
    ${@}
    return ${?}
}

# Getting options.
function usage() {
    # TODO - Complete this
    usage_str="
        Usage: ./$(basename $0)
"
    echo $usage_str 1>&2
}

DRY_RUN_SET=false
DRY_RUN_SET_ERR='Cannot provide --dry-run and --no-dry-run together or multiple times'
options=$(getopt --longoptions 'dry-run,no-dry-run' -o '' -- "${@}")
if [[ ${?} != 0 ]]; then
    usage
    exit 1
fi

for option in ${options}; do
    echo "option: [${option}]"
    case "${option}" in
    '--dry-run')
        if ${DRY_RUN_SET}; then
            echo_error ${DRY_RUN_SET_ERR}
            exit 1
        fi
        DRY_RUN_SET=true
        DRY_RUN=true
        ;;
    '--no-dry-run')
        if ${DRY_RUN_SET}; then
            echo_error ${DRY_RUN_SET_ERR}
            exit 1
        fi
        DRY_RUN_SET=true
        DRY_RUN=false
        ;;
    '--') ;;

    *)
        echo_error "Unknown option [${option}]"
        usage
        exit 1
        ;;
    esac
done
unset DRY_RUN_SET_ERR
unset DRY_RUN_SET

PLATFORM_CONFIG_PATH_VSCODE=$(get_value_for_platform "${HOME}/.config/Code - OSS/User" 'toast') # TODO - Find out what goes here for Darwin.

# Setup basic directory paths first.
echo_header 'Creating env directories'
for d in "${HOME}/.local/"{'aliases','bin','functions'}; do
    if [[ -d "${d}" ]]; then
        echo_info "Not creating directory [$d], already exists"
        continue
    fi
    echo_info "Creating directory [${d}]"
    run_cmd mkdir "${d}"
done

echo_header 'Linking env aliases and functions'
for d in 'aliases' 'functions'; do
    dotfiles_link_path="${HOME}/.local/${d}/dotfiles_${d}"
    if [[ -L "${dotfiles_link_path}" ]]; then
        echo_info "Not creating link [${dotfiles_link_path}], already exists"
        continue
    fi
    echo_info "Creating link [${dotfiles_link_path}]"
    run_cmd ln -s "${BASEDIR}/${d}" "${dotfiles_link_path}"
done

# Copy dotfiles
echo_header 'Copying dotfiles'
for f in $(find "${BASEDIR}/dotfiles/" -type f); do
    dotfile_dst=$(head -2 ${f} | tail -1 | sed 's/^. //')
    dotfile_dst="${dotfile_dst/#~/${HOME}}"

    if [[ -f "${dotfile_dst}" ]]; then
        if diff --brief "${dotfile_dst}" "${f}" &>/dev/null; then
            echo_info "Files [${dotfile_dst}] and [${f}] match, continuing"
        else
            echo_warning "Files [${dotfile_dst}] and [${f}] differ!"
        fi
        continue
    elif [[ -e "${dotfile_dst}" ]]; then
        echo_error "File [${dotfile_dst}] exists but is not a regular file!"
        continue
    fi

    echo "Copying file [${f}] to [${dotfile_dst}]"
    run_cmd cp "${f}" "${dotfile_dst}"
done

echo_header 'Copying VSCode snippets'
for f in $(find "${BASEDIR}/configs/vscode/snippets/" -type f); do
    snippet_link_name="dotfiles_$(basename ${f})"
    snippet_link_path="${PLATFORM_CONFIG_PATH_VSCODE}/snippets/${snippet_link_name}"

    if [[ -L "${snippet_link_path}" ]]; then
        echo "VSCode snippet file [${snippet_link_name}] already exists"
        continue
    fi
    echo "Creating snippet file [${snippet_link_name}] link"
    run_cmd ln -s "${f}" "${snippet_link_path}"
done
