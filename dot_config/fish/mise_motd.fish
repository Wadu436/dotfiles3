### Startup notice when the global mise toolset needs attention.
#
# Split into two clocks, like the chezmoi notice's fetch: the network sweep
# (`mise outdated`) only records what upstream's latest version is, while every
# refresh re-reads the locally installed versions and joins them against that
# record. So an upgrade clears the notice immediately, offline, and `mise
# --offline outdated` — which just answers `{}` — is never needed.

motd_register (status filename)

# How often upstream is asked for latest versions. Long, like the repo fetch.
set -q MISE_MOTD_FETCH_TTL; or set -g MISE_MOTD_FETCH_TTL 21600

function __mise_motd_missing
    mise ls --global --missing --json 2>/dev/null |
        jq -r 'to_entries[] | .key as $t | .value[] | "\($t)@\(.requested_version // .version)"' 2>/dev/null
end

# mise still exits 0 when it can't reach an upstream, so an offline run would
# silently look like "everything is current". Only trust a clean run.
function __mise_motd_fetch_latest --argument-names dir
    set -l err $dir/latest.err
    set -l json (mise --cd $HOME outdated --json 2>$err | string collect)
    set -l failed (string match -r 'error sending request|Error getting latest version|no versions found' <$err)
    command rm -f $err

    if test -n "$failed"; or test -z "$json"
        return 1
    end

    # Tools absent from `outdated` are current, so an empty map means all clear.
    printf '%s' $json |
        jq '[to_entries[] | {key: .key, value: .value.latest}] | from_entries' >$dir/latest.tmp 2>/dev/null
    or return 1

    command mv -f $dir/latest.tmp $dir/latest.json
    command date +%s >$dir/last-fetch
end

# Purely local: what's installed now vs the last known upstream latest.
function __mise_motd_outdated --argument-names dir
    if not test -s $dir/latest.json
        return 0
    end
    mise ls --global --json 2>/dev/null | jq -r --slurpfile latest $dir/latest.json '
        ($latest[0] // {}) as $known
        | to_entries[]
        | .key as $tool
        | .value[]
        | select(.installed and .active)
        | select($known[$tool] != null and $known[$tool] != .version)
        | "\($tool) \(.version)→\($known[$tool])"' 2>/dev/null
end

function __motd_report_mise
    if not type -q mise; or not type -q jq
        return 0
    end

    set -l dir (__motd_dir mise)

    set -l missing (__mise_motd_missing)
    if test (count $missing) -gt 0
        echo (set_color yellow)"mise: "(count $missing)" tool(s) not installed"(set_color normal)" ("(motd_summarise $missing)") — run "(set_color --bold)"mise install"(set_color normal)
    end

    motd_sync mise $MISE_MOTD_FETCH_TTL __mise_motd_fetch_latest

    set -l outdated (__mise_motd_outdated $dir)
    if test (count $outdated) -gt 0
        echo (set_color blue)"mise: "(count $outdated)" update(s) available"(set_color normal)" ("(motd_summarise $outdated)") — run "(set_color --bold)"mise upgrade"(set_color normal)
    end
end
