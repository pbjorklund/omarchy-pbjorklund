#!/bin/bash
# Launch a shell function in a floating terminal that closes after execution
# Usage: launch-tui-function.sh <function_name> [terminal_class]

set -e

function_name="$1"
terminal_class="${2:-tui-function}"

if [[ -z "$function_name" ]]; then
    echo "Usage: $0 <function_name> [terminal_class]"
    exit 1
fi

# Launch terminal with the function
exec alacritty --class "$terminal_class" -e bash -c "export SKIP_FASTFETCH=1; bash -i -c \"$function_name\""