# Helix configuration

Run `./install.sh` to copy this configuration to `${XDG_CONFIG_HOME:-~/.config}/helix`.
Existing files that differ are saved in a new `backup.*` directory inside the Helix
configuration directory. Running the script again leaves identical files alone.

The installer installs missing dependencies using pacman, apt, dnf, or Homebrew,
and may prompt for sudo. It installs Rust using rustup if needed, adds the
rust-analyzer and Clippy components, installs Bacon and Zellij with Cargo, and
installs Pyright and Prettier under `~/.local` using npm. Package availability
varies by distribution; if a package is unavailable, install it using your
distribution's instructions and rerun the script. Helix, Git, curl, lazygit,
Ruff, Node.js and npm are also required. Cargo installations can take time.

The script installs the `hx-lazygit` and `hx-bacon` helpers into `~/.local/bin`.
For Fish it installs the `hx` function automatically. For other shells it installs
`hx.sh` in the Helix configuration directory; source that file from your shell's
startup file to enable the wrapper. Ensure `~/.local/bin` and `~/.cargo/bin` are
on your PATH. Outside Zellij, the helpers require Alacritty or Konsole.
