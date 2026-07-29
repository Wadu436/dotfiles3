source ~/.config/fish/functions.fish
source ~/.config/fish/aliases.fish
source ~/.config/fish/secrets.fish
source ~/.config/fish/machine.fish

if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q atuin
        atuin init fish --disable-ctrl-r --disable-up-arrow | source
    end
end

set -gx COREPACK_ENABLE_AUTO_PIN 0

set -gx EDITOR nvim
set -gx TG_NO_AUTO_APPROVE true
set -gx TG_PARALLELISM 4
set -gx TG_PROVIDER_CACHE true
set -gx COMPOSE_BAKE true

# jj completions 
COMPLETE=fish jj | source

# Log every command
function log_command --on-event fish_preexec
    set timestamp (date "+%Y-%m-%dT%H:%M:%S%z")
    echo "$timestamp | $argv" >>~/.fish_command_log
end

# enable the starship prompt
starship init fish | source

# enable mise
mise activate fish | source

# https://github.com/magenta404/natural-selection
if functions --query _natural_selection
    bind escape '_natural_selection end-selection'
    bind ctrl-r '_natural_selection history-pager'
    bind up '_natural_selection up-or-search'
    bind down '_natural_selection down-or-search'
    bind left '_natural_selection backward-char'
    bind right '_natural_selection forward-char'
    bind shift-left '_natural_selection backward-char --is-selecting'
    bind shift-right '_natural_selection forward-char --is-selecting'
    bind super-left '_natural_selection beginning-of-line'
    bind super-right '_natural_selection end-of-line'
    bind super-shift-left '_natural_selection beginning-of-line --is-selecting'
    bind super-shift-right '_natural_selection end-of-line --is-selecting'
    bind alt-left '_natural_selection backward-word'
    bind alt-right '_natural_selection forward-word'
    bind alt-shift-left '_natural_selection backward-word --is-selecting'
    bind alt-shift-right '_natural_selection forward-word --is-selecting'
    bind delete '_natural_selection delete-char'
    bind backspace '_natural_selection backward-delete-char'
    bind super-delete '_natural_selection kill-line'
    bind super-backspace '_natural_selection backward-kill-line'
    bind alt-backspace '_natural_selection backward-kill-word'
    bind alt-delete '_natural_selection kill-word'
    bind super-c '_natural_selection copy-to-clipboard'
    bind super-x '_natural_selection cut-to-clipboard'
    bind super-v '_natural_selection paste-from-clipboard'
    bind super-a '_natural_selection select-all'
    bind super-z '_natural_selection undo'
    bind super-shift-z '_natural_selection redo'
    bind '' kill-selection end-selection self-insert
end

source /Users/warre/.safe-chain/scripts/init-fish.fish # Safe-chain Fish initialization script
# aikido-endpoint-cert-config-start
# Allow Node.js tooling to trust the SafeChain MITM CA while preserving public roots.
set -gx NODE_EXTRA_CA_CERTS "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-node-combined-ca.pem"
# aikido-endpoint-cert-config-end
# aikido-endpoint-pip-cert-config-start
# Allow Python package managers to trust the SafeChain MITM CA while preserving user-provided roots.
set -gx PIP_CERT "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
set -gx REQUESTS_CA_BUNDLE "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
set -gx POETRY_CERTIFICATES_PYPI_CERT "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-pip-combined-ca.pem"
set -gx UV_SYSTEM_CERTS true
# aikido-endpoint-pip-cert-config-end
# aikido-endpoint-ruby-cert-config-start
# Allow Ruby Bundler to trust the SafeChain MITM CA while preserving public roots.
set -gx BUNDLE_SSL_CA_CERT "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-ruby-combined-ca.pem"
# aikido-endpoint-ruby-cert-config-end
# aikido-endpoint-curl-cert-config-start
# Allow curl and other OpenSSL-linked tools to trust the SafeChain MITM CA while preserving the system roots.
set -gx SSL_CERT_FILE "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-openssl-combined-ca.pem"
set -gx CURL_CA_BUNDLE "/Library/Application Support/AikidoSecurity/EndpointProtection/run/endpoint-protection-openssl-combined-ca.pem"
# aikido-endpoint-curl-cert-config-end
