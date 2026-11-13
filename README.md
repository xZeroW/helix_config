# Helix configuration

Run `./install.sh` to copy this configuration to `${XDG_CONFIG_HOME:-~/.config}/helix`.
Existing files that differ are saved in a new `backup.*` directory inside the Helix
configuration directory. Running the script again leaves identical files alone.

The configuration expects Helix and, for the relevant language features,
`rust-analyzer`, Clippy, `pyright-langserver`, `ruff`, and `prettier` to be
installed separately. The configured key bindings also use `hx-lazygit` and
`hx-bacon`; install those helpers separately if you want to use them.
