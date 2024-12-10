#!/bin/sh
echo -ne '\033c\033]0;Project4\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Project4.x86_64" "$@"
