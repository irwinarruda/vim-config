# Vim Configs

Vim configs for the main editors I use. Some of them are more complex than others depending on how much I use the editor.

## Neovim Config

I'm trying to create a better and more concise development environment using Neovim. It's been a challenge, but I'm satified with the config I have right now.

### Install and symlink

Use Neovim 0.12 or newer. On Linux, the official [Neovim release archive](https://neovim.io/doc/install/) can be extracted into `~/.local/opt/nvim`, with its `bin/nvim` linked into `~/.local/bin`. Keep `~/.local/bin` on `PATH`.

```bash
mkdir -p ~/Documents/CONFIGS ~/.config
git clone https://github.com/irwinarruda/vim-config.git ~/Documents/CONFIGS/vim-config
ln -s ~/Documents/CONFIGS/vim-config/nvim ~/.config/nvim
```

If the checkout already exists, update it with `git -C ~/Documents/CONFIGS/vim-config pull --ff-only` instead of cloning. Back up an existing `~/.config/nvim` before creating the symlink.

### Linux prerequisites

On Ubuntu/Debian:

```bash
sudo apt-get install git curl unzip build-essential ripgrep fd-find python3-venv golang-go default-jre-headless
```

Node.js and npm must be on `PATH` for the JavaScript/TypeScript language servers and formatters. The C# server also needs the .NET runtime. Install the [Tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/releases) (0.26.1 or newer) on `PATH`; the current parser installer requires it in addition to a C compiler.

Open `nvim` to install the plugins and syntax parsers. Run `:MasonToolsInstallSync` to finish installing the configured language servers, formatters, and JavaScript debugger. Use `:checkhealth` to check the installation. The optional Nginx formatter can be installed separately with `pipx install nginxfmt`.

### WSL terminal and clipboard

Use an installed UTF-8 locale (`locale -a` lists them). If a terminal forwards an unavailable locale and Zsh prints `manpath: can't set the locale` or `character not in range`, put this before other setup in `~/.zshenv`:

```sh
export LANG=C.UTF-8
export LC_CTYPE=C.UTF-8
export LC_ALL=C.UTF-8
```

Restart the shell with `exec zsh -l`. Use a Nerd Font in the Windows terminal for prompt symbols and Neovim icons.

For the Windows clipboard, put the `win32yank.exe` from the official [win32yank release](https://github.com/equalsraf/win32yank/releases) in `~/.local/bin` and make it executable. Neovim detects it automatically; no clipboard override is needed. Native Linux can use `wl-clipboard` on Wayland or `xclip` on X11.

### Colorscheme

Dracula Pro is loaded from `stdpath("data")/themes/dracula_pro` (`~/.local/share/nvim/themes/dracula_pro` on Linux). Copy your licensed theme there separately; it is not included in this repository. When it is absent, the config uses Tokyo Night Moon instead. Neither theme needs a machine-specific path in the config.

---

### Tmux

- ctrl+a + r to reload tmux.conf
- ctrl+a + s to see tmux sessions
- ctrl+a + d to detach from session
- ctrl+a + c to create new window
- ctrl+a + n to move to next window
- ctrl+a + p to move to previous window
- ctrl+a + & to kill window
- ctrl+a + q to kill session
- ctrl+a + [ to go to copy mode
- q to quit copy mode
