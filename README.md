# Vim Configs

Vim configs for the main editors I use. Some of them are more complex than others depending on how much I use the editor.

## Neovim Config

I'm trying to create a better and more concise development environment using Neovim. It's been a challenge, but I'm satified with the config I have right now.

### Prepare

Copy the repo code to the `.config`.

```bash
# MacOS
$ rm -rf ~/.config/nvim
$ cp -r $PATH_TO_REPO/nvim ~/.config/nvim
```

Copy the `.config` code to the repo.

```bash
# MacOS
$ rm -rf $PATH_TO_REPO/nvim
$ cp -r ~/.config/nvim $PATH_TO_REPO/nvim
```

### Symlink

```bash
$ ln -sP $PATH_TO_REPO/nvim ~/.config
```

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
