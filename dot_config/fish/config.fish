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
