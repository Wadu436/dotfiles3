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
    if git rev-parse --is-inside-work-tree > /dev/null 2> /dev/null
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