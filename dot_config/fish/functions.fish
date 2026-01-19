# Better FZF
# Usage: pipe input into bfzf, filter with the arguments to bfzf
# Examples:
# ls | bfzf foo
function bfzf
    set -l stdin
    while read line
        set stdin $stdin $line
    end

    set -l filtered (printf "%s\n" $stdin | rg -i "$argv")

    if test (count $filtered) -eq 1
        echo $filtered
    else if test (count $filtered) -gt 0
        printf "%s\n" $filtered | fzf --exact --height=40% --layout=reverse --info=inline
    else
        return 1
    end
end

# bfzf + cd
function cdfzf
    set -l stdin
    while read line
        set stdin $stdin $line
    end

    set -l output (printf "%s\n" $stdin | bfzf $argv) && cd $output || true
end

function exportdotenv
    # List .env* files
    set -f dotenv_files (ls .env* 2>/dev/null)

    # Check if no dotenv files are found
    if test (count $dotenv_files) -eq 0
        echo "No .env files found. Aborting."
        return
    end

    # If there's only one dotenv file, use it directly
    if test (count $dotenv_files) -eq 1
        set -f dotenv_file $dotenv_files[1]
    else
        # Otherwise, let the user select a file using fzf
        set -f dotenv_file (printf "%s\n" $dotenv_files | fzf --exact --height=40% --layout=reverse --info=inline)
        if test -z "$dotenv_file"
            echo "No file selected. Aborting."
            return
        end
    end

    # Read the contents of the selected file
    set -f dotenv_content (cat $dotenv_file | grep -v '^#' | grep -v '^\s*$' )

    # Process each line in the file
    for line in $dotenv_content
        # Remove inline comments and split into key-value pairs
        set -f stripped_line (string split -m 1 -- "#" $line | head -n 1)
        set -f key (string split -m 1 -- "=" $stripped_line | head -n 1)
        set -f value (string split -m 1 -- "=" $stripped_line | tail -n 1 | string trim -c '"')

        # Export the variable if both key and value are valid
        if test -n "$key" -a -n "$value"
            echo "$key: \"$$key\" -> \"$value\""
            set -gx $key $value
        end
    end
end

function openremote
    # Check if inside a git repository
    if git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
        # Get the remote URL (defaulting to 'origin')
        set remote (git config --get remote.origin.url)

        if test -n "$remote"
            # Transform SSH URL (git@github.com:user/repo.git) to HTTPS
            if string match -rq '^git@' -- $remote
                set remote (string replace -r '^git@([^:]+):' 'https://$1/' -- $remote)
            end

            # Remove .git suffix if present
            set remote (string replace -r '\.git$' '' -- $remote)

            # echo $remote
            open $remote
        else
            echo "No remote URL set for 'origin'."
        end
    else
        echo "Not inside a git repository."
    end
end

function tokei-diff --description "Compare lines of code between two JJ commits using tokei"
    set -l rev1 $argv[1]
    set -l rev2 $argv[2]

    # defaults: compare parent to current
    if test -z "$rev1"
        set rev1 "@-"
    end
    if test -z "$rev2"
        set rev2 "@"
    end

    set -l ws1 "loc-diff-"(random)"-1"
    set -l ws2 "loc-diff-"(random)"-2"
    set -l tmpdir1 (mktemp -d)
    set -l tmpdir2 (mktemp -d)
    set -l json1 (mktemp)
    set -l json2 (mktemp)

    function _cleanup --no-scope-shadowing
        jj workspace forget "$ws1" 2>/dev/null
        jj workspace forget "$ws2" 2>/dev/null
        rm -rf "$tmpdir1" "$tmpdir2" "$json1" "$json2" >/dev/null 2>&1
    end

    if not jj workspace add --name "$ws1" "$tmpdir1" -r "$rev1" >/dev/null 2>&1
        echo "failed to create workspace for $rev1" >&2
        _cleanup
        return 1
    end

    if not jj workspace add --name "$ws2" "$tmpdir2" -r "$rev2" >/dev/null 2>&1
        echo "failed to create workspace for $rev2" >&2
        _cleanup
        return 1
    end

    tokei --output json "$tmpdir1" >"$json1"
    tokei --output json "$tmpdir2" >"$json2"

    jq -rs '
        .[0] as $a | .[1] as $b |
        ([$a, $b | keys[]] | unique | map(select(. != "Total"))) as $langs |
        
        ($langs | map({
            lang: .,
            code: (($b[.].code // 0) - ($a[.].code // 0)),
            comments: (($b[.].comments // 0) - ($a[.].comments // 0)),
            blanks: (($b[.].blanks // 0) - ($a[.].blanks // 0))
        }) | map(. + {lines: (.code + .comments + .blanks)}) | map(select(.lines != 0)) | sort_by(-(.lines | fabs))) as $diffs |
        
        {
            code: (($b.Total.code // 0) - ($a.Total.code // 0)),
            comments: (($b.Total.comments // 0) - ($a.Total.comments // 0)),
            blanks: (($b.Total.blanks // 0) - ($a.Total.blanks // 0))
        } | . + {lines: (.code + .comments + .blanks)} | . as $total |
        
        ["H", "LANGUAGE", "CODE", "COMMENTS", "BLANKS", "LINES"],
        ($diffs[] | ["D", .lang, .code, .comments, .blanks, .lines]),
        ["T", "TOTAL", $total.code, $total.comments, $total.blanks, $total.lines]
        | @tsv
        ' "$json1" "$json2" | awk -F'\t' '
        BEGIN {
            red = "\033[31m"
            green = "\033[32m"
            bold = "\033[1m"
            dim = "\033[2m"
            reset = "\033[0m"
            lang_w = 18
            num_w = 10
            line_w = lang_w + 1 + (num_w + 1) * 4
        }
        function printnum(n, w) {
            if (n ~ /^-/) printf "%s%*s%s", red, w, n, reset
            else if (n + 0 > 0) printf "%s%*s%s", green, w, n, reset
            else printf "%*s", w, n
        }
        function separator() {
            printf dim
            for (i = 0; i < line_w; i++) printf "-"
            printf reset "\n"
        }
        $1 == "H" { 
            printf bold "%-*s %*s %*s %*s %*s" reset "\n", lang_w, $2, num_w, $3, num_w, $4, num_w, $5, num_w, $6
            next 
        }
        $1 == "D" { 
            printf "%-*s ", lang_w, $2
            printnum($3, num_w); printf " "
            printnum($4, num_w); printf " "
            printnum($5, num_w); printf " "
            printnum($6, num_w); printf "\n"
            next 
        }
        $1 == "T" { 
            separator()
            printf bold "%-*s " reset, lang_w, $2
            printnum($3, num_w); printf " "
            printnum($4, num_w); printf " "
            printnum($5, num_w); printf " "
            printnum($6, num_w); printf "\n"
        }
    '

    _cleanup
    functions -e _cleanup
end
