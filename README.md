# symfiles

`.dotfiles` management system.

Keep track of all your configuration files on your system 🗂️

![Symfiles Logo](./src/imgs/sym-logo.png)

To use this repo fork it and modify it as you see fit.

> [!NOTE]  
> First things first, treat the `dots` directory as your `$HOME` directory on your system,
> structure all of these files accordingly.
>
> This is an example of what the `dot` files mapped to the system.
>
> ```txt
> dots/               -> $HOME/
> ├─ config/          -> ├─ config/
> │  ├─ git/          -> │  ├─ git/
> │  │  ├─ config     -> │  │  ├─ config
> ├─ .zshrc           -> ├─ .zshrc
> ```

## Usage

```txt
make <command>
```

These are the available commands, all used by `make`.

### Link

- link
- clean
- update

### Install

- install
- install-clean

### Log

- log
- log-raw

### Test

- test
- test-fix
