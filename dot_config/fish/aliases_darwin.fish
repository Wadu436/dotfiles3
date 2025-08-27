alias mintlify "pnpm dlx mintlify"

function yoink -a file
    set -l absolute_path $(realpath $file)
    osascript -e "set the clipboard to (POSIX file \"$absolute_path\")"
    echo "Copied \"$file\" to clipboard."
end
alias y yoink
