function hx --description 'Open Helix inside Zellij (needed for the lazygit popup)'
    set -l editor hx
    if command -q helix
        set editor helix
    end
    if set -q ZELLIJ
        command $editor $argv
        return
    end

    if not command -q zellij
        echo "hx: zellij is not installed, opening Helix without the git popup" >&2
        command $editor $argv
        return
    end

    set -l name "hx-$fish_pid-"(random)
    zellij attach -c $name --close-on-exit -- $editor $argv
end
