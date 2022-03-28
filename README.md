# About

Building a consistent Debian GNU/Linux "seed" installer image as done by
[penguinspiral/seed-installer](https://github.com/penguinspiral/seed-installer)
requires "static" local package repositories.

Unlike traditional Debian GNU/Linux installers the customised "seed" image
contains the _entire_ official Debian AMD64 architecture package repository
_locally_. This provides a guarantee of configuration management to software
packaging interoperability (see: [rationale]https://github.com/penguinspiral/seed-installer#rationale).

Originally the Debian GNU/Linux AMD64 repository was synced locally in a _manual_
fashion via [debmirror(1)](https://linux.die.net/man/1/debmirror). This Git
repository is the formalisation (and extension) of this effort to simplify "Day
1" operations.


# Implementation

At its core 'seed-mirrors' is a `for` loop around a set of `debmirror`
configuration files.

`debmirror` was chosen as it supports mirroring a "partial" (i.e. architecture &
release targetable) Debian GNU/Linux mirror which satisfied the requirements of
[penguinspiral/seed-installer](https://github.com/penguinspiral/seed-installer).

Operationally it shares several design decisions with the 
[penguinspiral/seed-installer](https://github.com/penguinspiral/seed-installer)
repository by leveraging `docker` for dependency & run-time abstraction and GNU
`make` for presenting a standardised usage interface.


## Limitations

During development there were several concessions made to simplify
implementation at the cost of overall configurability & efficiency:

* Upstream repositories are synchronised sequentially

* Upstream repositories _must_ support the `rsync` transport method (`debmirror`
requirement)

* An error during `debmirror` runtime results in the container exiting

* All GPG keys are added to the GPG Keyring _regardless_ of upstream targeting


# Usage

## Mirroring

```
make mirrors
```

Synchronises _all_ upstream repositories located under the `conf/debmirror/**`
directory _after_ sourcing all GPG keys located under the `conf/gpg.d`
directory.
**Important**: Local mirrored copies are stored under the `mirror` directory
_relative_ to the `seed-mirrors` Git repository. This is _likely_ undesirable
and can be configured with the `MIRRORS_ROOT` `make` variable (see below).

```
make MIRRORS_ROOT=/host/storage/path/ mirrors
```

Synchronises _all_ upstream repositories located under the `conf/debmirror/**`
directory _after_ sourcing all GPG keys located under the `conf/gpg.d`
directory.
Local mirrored copies are stored under the host's `/host/storage/path`
directory.


```
make MIRRORS_ROOT=/host/storage/path TARGET='debian/bullseye puppetlabs/bullseye' mirrors
```

Synchronises the `debian/bullseye` (`conf/debmirror/debian/bullseye.conf`) and
`puppetlabs/bullseye` (`conf/debmirror/puppetlabs/bullseye.conf`) upstream
repositories only, _after_ sourcing all GPG keys located under the `conf/gpg.d`
directory. 


## Extending

### Mirrors

`debmirror` based configuration files targeting upstream repositories are
located under the `conf/debmirror` directory. Configurations are organised by
the overarching "project" (e.g. Puppetlabs) with the name of the configuration
file itself being the Debian GNU/Linux distribution codename (e.g. bullseye.conf)
```
conf/debmirror/$PROJECT/$DEBIAN_DIST.conf
```

### GPG Keys

Modern secure APT repositories have their `dists/$DIST/InRelease' file
["clearsigned"](https://www.gnupg.org/gph/en/manual/x135.html) by the "project"'s
private GPG key. Older APT repositories may leverage a separate
'dists/$DIST/Release' and corresponding, "detached" `dists/$DIST/Release.gpg'
GPG signature file ([source](https://wiki.debian.org/DebianRepository/Format#Overview)).

'seed-mirrors' imports _all_ GPG public keys (extension `.gpg`) located under
the `conf/gpg.d` directory at runtime _before_ synchronising upstream repositories.

`debmirror` configuration permits ignoring both the modern 'InRelease' "clearsign"
and older detached GPG signature 'Release.gpg' via the `$ignore_releases` and `$ignore_release_gpg`
options respectively.
Important: Consider the security implications before disabling signature
verification.


## Debugging

By design the 'seed-mirrors' script redirects both STDOUT and STDERR of each
`debmirror` invocation to a dedicated runtime log file. This log file is located
in the root of the 'seed-mirrors' repository.

For problematic upstream repositories I'd recommend targeting (via the `make`
variable `TARGET=`) to skip existing functional upstream repositories.
