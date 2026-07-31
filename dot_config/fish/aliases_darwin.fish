alias mintlify "pnpm dlx mintlify"

function ensure_env
    if not test -n "$_OP_ENV_LOADED"
        opl
    end
end

function yoink -a file
    set -l absolute_path $(realpath $file)
    osascript -e "set the clipboard to (POSIX file \"$absolute_path\")"
    echo "Copied \"$file\" to clipboard."
end
alias y yoink

function claude --wraps=claude --description 'Run Claude Code with 1Password-resolved env'
    ensure_env
    command claude $argv
end

function glab --wraps=glab --description "Run Gitlab with the 1Password-resolved env"
    ensure_env
    command glab $argv
end
