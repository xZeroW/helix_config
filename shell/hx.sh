# Source this file in a POSIX-compatible shell to use Helix inside Zellij.
hx() {
    if command -v helix >/dev/null 2>&1; then
        _hx_editor=helix
    else
        _hx_editor=hx
    fi
    if [ -n "${ZELLIJ:-}" ] || ! command -v zellij >/dev/null 2>&1; then
        command "$_hx_editor" "$@"
    else
        zellij attach -c "hx-$$" --close-on-exit -- "$_hx_editor" "$@"
    fi
}
