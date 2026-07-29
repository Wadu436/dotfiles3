### Startup notice when the chezmoi-managed config has drifted.

motd_register (status filename)

# How often the source repo is fetched and rebased (needs the network, so it
# gets a much longer interval than the notice itself).
set -q CHEZMOI_MOTD_FETCH_TTL; or set -g CHEZMOI_MOTD_FETCH_TTL 21600

# Fetch upstream and move local work on top of it. Both halves are undoable in
# jj, and a rebase that would only hand the user conflicts is rolled back.
function __chezmoi_motd_sync --argument-names dir
    set -l src (chezmoi source-path 2>/dev/null)
    if test -z "$src"
        return 1
    end

    if __chezmoi_motd_sync_repo $src
        command date +%s >$dir/last-fetch
    end
end

function __chezmoi_motd_sync_repo --argument-names src
    if test -d $src/.jj; and type -q jj
        jj --repository $src git fetch >/dev/null 2>&1; or return 1
        jj --repository $src rebase -b @ -d 'trunk()' >/dev/null 2>&1
        set -l conflicted (jj --repository $src log --no-graph --ignore-working-copy \
            -r 'trunk()..@ & conflicts()' -T '"x"' 2>/dev/null)
        if test -n "$conflicted"
            jj --repository $src undo >/dev/null 2>&1
        end
    else if type -q git
        git -C $src fetch --quiet >/dev/null 2>&1; or return 1
        git -C $src pull --rebase --autostash --quiet >/dev/null 2>&1
    else
        return 1
    end
end

function __chezmoi_motd_behind --argument-names src
    if not test -d $src/.jj; or not type -q jj
        return 1
    end
    # Non-empty when trunk holds commits the working copy isn't built on.
    set -l ahead (jj --repository $src log --no-graph --ignore-working-copy \
        -r 'trunk() ~ ::@' -T '"x"' 2>/dev/null)
    test -n "$ahead"
end

function __motd_report_chezmoi
    if not type -q chezmoi
        return 0
    end

    motd_sync chezmoi $CHEZMOI_MOTD_FETCH_TTL __chezmoi_motd_sync

    set -l src (chezmoi source-path 2>/dev/null)

    # Column 2 is 'R' for scripts, which chezmoi re-runs on every apply and which
    # would otherwise make the config look permanently outdated.
    set -l pending (chezmoi status 2>/dev/null | string match -rv '^.R ')

    if test (count $pending) -gt 0
        set -l files (printf '%s\n' $pending | string replace -r '^.. ' '')
        echo (set_color yellow)"dotfiles: "(count $files)" out of date"(set_color normal)" ("(motd_summarise $files)") — run "(set_color --bold)"chezmoi apply"(set_color normal)
    end

    if test -n "$src"; and __chezmoi_motd_behind $src
        echo (set_color yellow)"dotfiles: source repo is behind origin"(set_color normal)" — run "(set_color --bold)"jj -R $src rebase -b @ -d 'trunk()'"(set_color normal)
    end
end
