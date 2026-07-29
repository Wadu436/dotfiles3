### Shared plumbing for the startup notices ("motd").
#
# A notice is a `__motd_report_<name>` function that echoes its lines. It runs
# synchronously at shell start — every check it makes is local and costs a few
# tens of milliseconds — so what it prints is always the truth right now.
#
# Only the networked half (asking upstream what exists) is deferred: `motd_sync`
# runs it detached on a long TTL, and the next shell picks up the result from
# the notice's state dir.
#
# Coreutils are called through `command` on purpose: the interactive aliases
# (mkdir -p, rm -iv, cat=bat) would defeat the lock below and garble output.

set -g __motd_lib (status filename)
set -g __motd_sources

function motd_register --argument-names file --description "Let the background refresher re-source this notice provider"
    if not contains -- $file $__motd_sources
        set -a __motd_sources $file
    end
end

function __motd_dir --argument-names name
    if set -q XDG_STATE_HOME
        echo $XDG_STATE_HOME/motd/$name
    else
        echo $HOME/.local/state/motd/$name
    end
end

function motd_stale --argument-names file ttl --description "True when the stamp file is missing, unreadable or older than ttl seconds"
    if not test -r $file
        return 0
    end
    set -l stamp (command cat $file 2>/dev/null | string trim)
    if not string match -qr '^\d+$' -- "$stamp"
        return 0
    end
    test (math (command date +%s) - $stamp) -ge $ttl
end

function motd_summarise --description "Join items for display, eliding everything past the third"
    set -l items $argv
    if test (count $items) -eq 0
        return 0
    end
    set -l summary (string join ', ' $items[1..(math "min(3, "(count $items)")")])
    if test (count $items) -gt 3
        set summary "$summary, +"(math (count $items) - 3)" more"
    end
    echo $summary
end

function motd_show --argument-names name --description "Print a notice"
    set -l provider __motd_report_$name
    if functions -q $provider
        $provider
    end
end

# Deliberately cheap and non-blocking: the caller's shell only reads a stamp,
# then hands the slow part to a detached shell.
function motd_sync --argument-names name ttl refresher --description "Kick off a notice's networked refresh at most once per ttl"
    if not motd_stale (__motd_dir $name)/last-fetch $ttl
        return 0
    end

    set -l boot "source $__motd_lib"
    for file in $__motd_sources
        set boot "$boot; source $file"
    end
    fish --no-config --command "$boot; __motd_sync_run $name $ttl $refresher" >/dev/null 2>&1 &
    disown 2>/dev/null
end

function __motd_sync_run --argument-names name ttl refresher
    set -l dir (__motd_dir $name)
    command mkdir -p $dir

    # mkdir is the atomic bit — several shells may have raced to spawn this.
    if not command mkdir $dir/lock 2>/dev/null
        # A refresher killed mid-run would otherwise wedge the lock forever.
        if not motd_stale $dir/lock/stamp 600
            return 0
        end
        command rm -rf $dir/lock
        command mkdir $dir/lock 2>/dev/null; or return 0
    end
    command date +%s >$dir/lock/stamp

    # Re-check under the lock; a shell that raced us may already have refreshed.
    if motd_stale $dir/last-fetch $ttl
        # The refresher stamps last-fetch itself, and only when it succeeds.
        $refresher $dir >/dev/null 2>&1
    end

    command rm -rf $dir/lock
end
