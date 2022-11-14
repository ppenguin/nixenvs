# nixenvs

Nix shell envs for different purposes.

Usage (example for the `test` devshell, see flake outputs):

```sh
nix develop github:ppenguin/nixenvs#test
```

or better yet, with `direnv`, in `.envrc`:

```sh
#!/usr/bin/env bash
use flake "github:ppenguin/nixenvs#test" --impure
```

You could do without `--impure`, but some shells rely on `<unstable>` being pulled from your env (i.e. your `NIX_PATH=...:unstable=...`).
While this is not hermetic, it will cost you less traffic and disk-space.

Of course you can also add an unstable input to the flake.