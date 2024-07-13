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
