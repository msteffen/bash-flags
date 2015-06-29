###################################################
# Small bash library for simplifying the use of flags in bash scrips
###################################################
# Usage:
# 
### Include lib
# source "flags.sh"
#
### define variables that you'll use in your script, but that you want to be
### flag-configurable (now these can be set by running this script with
### --var_a="blah blah")
# MAKE_FLAG var_a "default value"
# MAKE_FLAG var_b
# PARSE_ALL_FLAGS $0 "${@}"
# ...
# echo "Using the value in var_a, which is ${var_a}"
###
# TODO:
# -Binary flags (--use_flux_capacitor and --nouse_flux_capacitor)

__FLAGS__=()
__FILL_DEFAULTS__=()

function MAKE_FLAG {
  __FLAGS__+=("$1::")
  __FILL_DEFAULTS__+=("$1=\"$2\"")
}

function PARSE_ALL_FLAGS {
  # Fill default values
  for cmd in "${__FILL_DEFAULTS__}"; do
    eval "${cmd}"
  done

  # First element of sys.argv is "-c" so omit that by joining argv[1:] instead
  local flags="$( python -c 'import sys; print ",".join(sys.argv[1:])' "${__FLAGS__[@]}" )"
  local OPTS=( $(getopt -n "$1" -l "${flags}" -- ${@:1}) )

  # Read all args to PARSE_ALL_FLAGS and use them to set the flag values
  while [[ "${#OPTS[@]}" -gt 1 ]] && [[ "${OPTS[0]}" != '--' ]]; do
    # :2 removes the "--" from the front of the long arg's name
    eval ${OPTS[0]:2}=${OPTS[1]}
    OPTS=( "${OPTS[@]:2}" )
  done
  echo "${OPTS[@]:1}"
}
