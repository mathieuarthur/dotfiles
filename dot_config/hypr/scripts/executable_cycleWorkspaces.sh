#!/bin/bash

# Get array of non-empty workspace IDs
mapfile -t workspaces < <(hyprctl workspaces | awk '
  /^workspace ID/ { id = $3 }
  /^\twindows:/ && $2 > 0 { print id }
')

# Get current workspace ID
current_ws=$(hyprctl activewindow | grep -Po 'workspace: \K\d+')

# Exit if no current workspace or no non-empty workspaces
[[ -z "$current_ws" || ${#workspaces[@]} -eq 0 ]] && exit 1

# Find current workspace index in non-empty workspaces
index=-1
for i in "${!workspaces[@]}"; do
    if [[ "${workspaces[i]}" == "$current_ws" ]]; then
        index=$i
        break
    fi
done

# If current workspace is empty (index == -1), start cycling at the first non-empty workspace (index 0)
next_index=$(( (index + 1) % ${#workspaces[@]} ))

hyprctl dispatch workspace "${workspaces[next_index]}"

