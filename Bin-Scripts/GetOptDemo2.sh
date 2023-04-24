#!/bin/bash
OPTIONS=f:v
LONGOPTS=force,verbose

# Parse command line options
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")

# Extract the options and their arguments into variables
eval set -- "$PARSED"
while true; do
    case "$1" in
        -f|--force)
            force=true
            shift ;;
        -v|--verbose)
            verbose=true
            shift ;;
        --)
            shift; break ;;
        *)
            echo "Invalid argument: $1"
            exit 1 ;;
    esac
done

# Remaining arguments are non-option arguments
echo "Non-option arguments:"
for arg in "$@"; do
    echo "    $arg"
done

# Use the values of the variables as needed to perform some action
if [ "$force" = true ]; then
    echo "Force is enabled"
fi
if [ "$verbose" = true ]; then
    echo "Verbose is enabled"
fi
