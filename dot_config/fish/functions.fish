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
    if not jj root >/dev/null 2>&1
        echo "Not inside a jj repository."
        return 1
    end

    set remote (jj git remote list 2>/dev/null | string match -r '^origin\s+(\S+)' | tail -n 1)

    if test -z "$remote"
        echo "No remote URL set for 'origin'."
        return 1
    end

    # Transform SSH URL (git@host:user/repo.git) to HTTPS
    if string match -rq '^git@' -- $remote
        set remote (string replace -r '^git@([^:]+):' 'https://$1/' -- $remote)
    end

    set remote (string replace -r '\.git$' '' -- $remote)
    open $remote
end

function openmr --description "Open the current branch's MR in riff (default) or GitLab"
    argparse riff glab -- $argv
    or return 1

    if set -q _flag_riff; and set -q _flag_glab
        echo "Pass at most one of --riff and --glab."
        return 1
    end

    if not jj root >/dev/null 2>&1
        echo "Not inside a jj repository."
        return 1
    end

    set branch (jj bookmark list --revision 'closest_bookmark(@)' --template 'self.name() ++ "\n"' | head -n 1)

    if set -q _flag_glab
        glab mr view $branch --web
        return
    end

    set url (glab mr view $branch --output json --jq .web_url)
    or return 1

    # `riff open` takes no MR argument, so build riff's MR route directly.
    set port (riff status | string match -rg 'port (\d+)')
    or begin
        echo "riff is not running. Start it with `riff up`."
        return 1
    end

    set mr (string match -rg '^https?://[^/]+/(.+?)/-/merge_requests/(\d+)' -- $url)
    or begin
        echo "Not an MR URL: $url"
        return 1
    end

    open "http://127.0.0.1:$port/mr/gitlab/"(string replace -a / %2F -- $mr[1])"/$mr[2]"
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

function claude-ws --description "Create a jj workspace in <repo>/.worktrees and launch Claude Code in it"
    set -l repo_root (jj root 2>/dev/null)
    if test -z "$repo_root"
        echo "Not inside a jj repository." >&2
        return 1
    end
    set -l repo_name (basename "$repo_root")

    set -l hex (printf '%04x%04x' (random) (random))
    set -l ws_name "$repo_name-$hex"
    set -l ws_path "$repo_root/.worktrees/$ws_name"

    # Keep workspace dirs out of the parent working copy's snapshots.
    set -l ignore_file "$repo_root/.gitignore"
    if not grep -qxF '.worktrees/' "$ignore_file" 2>/dev/null
        printf '\n.worktrees/\n' >>"$ignore_file"
    end

    mkdir -p "$repo_root/.worktrees"

    if not jj workspace add --name "$ws_name" "$ws_path"
        return 1
    end

    cd "$ws_path"
    claude
end

function rdo --description "Run a command in another repository's directory without leaving this one"
    set -l repo $argv[1]
    set -l cmd $argv[2..]

    if test -z "$repo"
        echo "usage: rdo <repo> <command...>" >&2
        return 2
    end

    # An exact directory name wins outright, even when it prefixes other repos.
    set -l name
    if test -d ~/Repositories/$repo
        set name ~/Repositories/$repo
    else
        set name (ls -d ~/Repositories/* | bfzf $repo)
    end

    if test -z "$name"
        echo "No repository matching '$repo'." >&2
        return 1
    end

    # No command: just report where it would have run.
    if test (count $cmd) -eq 0
        echo $name
        return 0
    end

    pushd $name
    $cmd
    set -l rc $status
    popd
    return $rc
end
alias repodo rdo

function jjunamend --description "Move edits accidentally amended into a pushed commit onto a new child commit"
    set -l bm $argv[1]
    set -l msg $argv[2]

    if not jj root >/dev/null 2>&1
        echo "Not inside a jj repository." >&2
        return 1
    end

    # Default to the nearest bookmark at or below @
    if test -z "$bm"
        set bm (jj log -r 'closest_bookmark(@)' --no-graph \
            -T 'local_bookmarks.map(|b| b.name()).join("\n") ++ "\n"' 2>/dev/null | string trim | head -n 1)
    end

    if test -z "$bm"
        echo "jjunamend: no bookmark found — pass one explicitly." >&2
        return 1
    end

    if not jj log -r "$bm@origin" --no-graph -T '""' >/dev/null 2>&1
        echo "jjunamend: $bm has not been pushed (no $bm@origin)." >&2
        return 1
    end

    if test -z (jj diff --from "$bm@origin" --to "$bm" --name-only | string collect)
        echo "jjunamend: $bm already matches $bm@origin — nothing to split off." >&2
        return 1
    end

    if test -z "$msg"
        set msg "Follow-up change"
    end

    set -l old (jj log -r "$bm" --no-graph -T 'commit_id')

    # Branch off the pushed commit itself rather than restoring the local one, so
    # its commit id survives and the next push stays a fast-forward.
    jj new "$bm@origin" -m "$msg"; or return 1
    jj restore --from "$old" --into @; or return 1

    set -l kids (jj log -r "$old+" --no-graph -T '"x\n"')
    if test (count $kids) -gt 0
        jj rebase -s "$old+" -d @; or return 1
    end

    # Sideways move: the new child descends from the pushed commit, not from the
    # amended one the bookmark is currently on.
    jj bookmark set "$bm" -r @ --allow-backwards; or return 1
    jj abandon "$old"; or return 1

    echo "Split the amendment onto a new child; $bm now points at it. 'jj undo' repeatedly to revert."
    jj log
end
