# symfiles

`.dotfiles` management system.

Keep track of all your  configuration files on your system 🗂️

![MainLogo](./imgs/sym-logo.png)

This system will help you spread the files under the `dots` directory across
your system via [symbolic links](https://linux.die.net/man/1/ln).

## Table of Contents 🧱

1. [Usage](#usage)
2. [Commands](#commands)
    1. [make-link](#make-link)
    2. [make-clean](#make-clean)
    3. [make-update](#make-update)
    4. [make-install](#make-install-csv)
    5. [make-log](#make-log)
    6. [make-log-raw](#make-log-raw)
    7. [make-test](#make-test)
    8. [make-test-fix](#make-test-fix)

## Usage 🔧

1. Clone this `repo` so you can make it yours

2. Put all your files in the "[dots](/dots)" directory (picture this folder as
your home directory on your system)

3. And after you've done the previous steps you're done mate

The initial command for spreading for your files would be this one:

```bash
make link
```

Below are the commands for you to use (there are others but are for utilities)

## Commands 🖥️

Basic usage of the commands

```bash
make [command] [OPTION=*]
```

### `make link`

This command as explained earlier this command will spread the files over your
system.

This link also will take care of another directory of this `repo` named `secrets`,
this directory will work exactly the same way as the `dots` directory but with
one difference, it WILL NOT be tracked on this repository. This is for 'secret'
files like some `gpg`, `ssh`, etc...

Here is how the mapping between the files in the `dots` and `secrets` directory
will look like:

```
dots/foo                -> ~/foo
dots/.config/nvim/init  -> ~/.config/nvim/init

secrets/.password       -> ~/.password
secrets/.ssh/id_rsa     -> secrets/.ssh/id_rsa
```

### `make clean`

Cleans (deletes) all your files across the system. This will come handy if you
want to move the location of your `symfiles` `repo` to other location.

### `make update`

This is a combination of the commands `clean` + `link`. An example for this
command would be that you removed a file from the `repo` and the `link` is still
on your system, with this you eliminate all of the links and only add the ones
still in the `repo`.

### `make install [CSV=*]`

Notice that this will only work on these systems below:

- Arch Linux
- Macos

This will look for two needed files that comes with this `repo` as default
`*.csv` files for you to use which are

    config/apps-common.csv
    config/apps-mac.csv

and install any dependency you specify on them.

In the `CSV=*` variable you can specify any `*.csv` file(s) you want to use other
than the two common ones that are on the initial setup.

Example:

```bash
make install CSV="foo.csv bar.csv"
```

The above will install all the dependencies listed in the `foo.csv` and
`bar.csv` files.

#### These below are the meaning for each option you can use on the `*.csv` files

| Option | Name     | Description                                                               |
|--------|----------|---------------------------------------------------------------------------|
|        | main     | Empty means to use your `default` package manager                         |
| a      | aur      | Find packages on your `secondary` package manager                         |
| f      | function | This will look for a custom script under the `config/functions/<name>.sh` |
| g      | go       | Installs packages with go                                                 |
| gem    | gem      | Installs packages with ruby                                               |
| m      | make     | This is very specific for installing the `aur`                            |
| node   | node     | Installs packages with nodejs                                             |
| pip    | pip      | Installs packages with your version of python                             |

Note: Remember to activate the package manager you want to use for installing
any dependency before installing any package.

### `make log`

This will list all the installed packages and their status code. If some of
them cannot be installed correctly they will have an `1` as status code and `0`
if they are correctly installed.

Example:

`- node - :: peerflix :: 0`

### `make log-raw`

This print all the raw `stdout` for every installed package.

Example:

```bash
:: peerflix - node - ::
yarn global v1.21.1
[1/4] Resolving packages...
[2/4] Fetching packages...
info fsevents@1.2.11: The platform "linux" is incompatible with this module.
info "fsevents@1.2.11" is an optional dependency and failed compatibility check.
Excluding it from installation.
[3/4] Linking dependencies...
[4/4] Building fresh packages...
success Installed "peerflix@0.39.0" with binaries:
      - peerflix
Done in 2.20s.
```

### `make test`

Required: [shellcheck](https://www.shellcheck.net/) (it is on by default on the
`config/apps-common.csv` file)

This will test all your `*.sh` files in the `repo` and also any file on these two
directories

```
dots/.scripts
dots/.zsh
```

### `make test-fix`

This will open any file containing an `error` or a `warning` for you to edit
inside the glorious, marvelous, powerful, shiny, immune editor in the whole
world ... `neovim`. ❤️

## Todo

| Completed | Task                                                   |
|-----------|--------------------------------------------------------|
|           | Make this system use `*.yaml` for configurations       |
|           | Enable a custom editor for the `make-test-fix` command |

Leave any feedback [here](https://github.com/cabaalexander/symfiles/issues) 👾
