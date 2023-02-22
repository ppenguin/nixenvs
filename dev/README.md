# Dev Shell Specifics

## `flutter`

It appears to need some tweaking if you want to build and run flutter projects that depend on extra libs.

### Building

A few issues were encountered:

- `libdeflate` is an indirect dependency but current `nixpkgs` (`v1.8`) doesn't support `pkg-config` yet => PR to `nixpkgs` and in-flake pkg definition for direct usage
- indirect headers (in this case just `X11/Xlib.h`) could not be found, which was solved by explicitly adding it to the project's `linux/CMakeList.txt` as
  ```cmake
  find_package(X11 REQUIRED)
  include_directories(${X11_INCLUDE_DIR})
  ```
- somehow the linker used is `ld` from `binutils` instead of `lld` from `llvmPackages.bintools`, even if we set `LD=lld` and variations on this. This appears to affect whether we need to set additionally `LDFLAGS` to `NIX_LDFLAGS_FOR_TARGET` so `ld` can find the libraries. A better solution appears to force using `lld`, which seems to not need (or use) `LDFLAGS`, by adding to the project's `linux/CMakeList.txt`:
  ```cmake
  set(CMAKE_CXX_LINK_FLAGS "-fuse-ld=lld")
  ```

### Running

We have to set `LD_LIBRARY_PATH` either in a `shellHook` or we can also hack around it like this:

```sh
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pkg-config --libs-only-L pangocairo atk gdk-pixbuf-2.0 | sed -r 's/-L//g' | tr ' ' ':') my_flutter_built_exe
```

For the former method, it's the easiest to just define the target libs in the `nix` *dev-shell definition* as a list of packages (`libs = with pkgs; [ somelib ... ]`) and then do

```nix
shellHook = ''
  LD_LIBRARY_PATH=${lib.makeLibraryPath libs}
'';
```

Apparently when using `lld`, this is not necessary for most libs (it probably handles `-rpath` automatically from the env), but still for `libepoxy`.