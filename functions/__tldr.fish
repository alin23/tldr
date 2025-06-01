function __n_lines \
    --description 'Line counting helper function including lines from wrapping'
    # Needs at least one arg


    # Get each string's character count
    # Split on \n in case there are line breaks in the strings
    set -l lengths (
        string split \n $argv | string length
    )

    # Get the terminal width
    set -l width (echo cols | tput -S)

    # To avoid calling math multiple times in a loop
    set -l math_string (
        printf "(max 1,ceil (%s / $width))\n" $lengths \
        | string join '+'
    )

    math $math_string

end

function __tldr \
    --description "Integrate tldr with the fish shell. Meant to be used with keybinding"
    # Grab all tokens from the command line that do NOT start with '-'
    set -l args (commandline -po | string match -rv '^-')

    set line_count (__n_lines (commandline -bc))
    set prompt_height (fish_prompt | count)
    set line_count (math $line_count + $prompt_height)

    # If we have no tokens, just beep and return
    if not set -q args[1]
        printf \a
        return
    end


    echo -n \e\["$line_count"F\e\[0J

    # First token is the main command; second token might be a subcommand
    set -l maincmd (basename $args[1])

    # If there is a second token, we try tldr <maincmd>-<subcmd> first, then fallback
    if set -q args[2]
        # Attempt "tldr main-sub"

        tldr "$maincmd-$args[2]" 2> /dev/null
        or tldr "$maincmd" 2> /dev/null
        or printf \a
    else
        # Only one token, so just do "tldr main"
        tldr "$maincmd"
        or printf \a
    end

    string repeat -n (math  $line_count - $prompt_height) \n
end

