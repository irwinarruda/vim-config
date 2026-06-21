# clean-copy

Small Rust implementation of `clean-copy` for this tmux config.

It reads tmux copy/capture output from stdin, cleans terminal padding/gutters, and sends the result to macOS `pbcopy`.

## Usage

```sh
clean-copy [--rewrap]
```

- default: trim right-side terminal padding and remove the common left whitespace gutter
- `--rewrap`: additionally join terminal-wrapped prose while preserving common Markdown structure

## Build and install

From `tmux/`:

```sh
make build
```

Or from this directory:

```sh
make install
```

That installs the binary to `tmux/bin/clean-copy`, which is what `.tmux.conf` calls.

## Checks

```sh
make check
```
