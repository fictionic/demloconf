# demloconf

This is a complete configuration suite for Ambrevar's [Demlo](https://godoc.org/github.com/Ambrevar/demlo), aimed at maximizing the potential of its complete extensibility, in particular when it comes to metadata tagging.

(This readme is far from done)

## Overview

The scripts are prefixed with a number according to their function.

- `00*` provide global utility functions and settings, respectively.
- `01` are settings profiles, meant to specify path, encoding, and cover-art behavior for different types of situation. For example, are you creating MP3 rips of a folder of FLACs, or are you simply re-tagging?
- `02` are tools. Might be deleted in favor of the cmdline settings parsing system.
- `1*` pertain to metadata tags. `tag-fields` deals with the fields alone, while `tag-contents` deals with their contents.
- `20` is encoding.
- `3*` pertain to the output filepath.
- `40` pertains to cover art.
- `99` are are wrappers for Demlo settings, meant to override the result of the scripts.

## Configuration

Global settings are stored in `001-globals.lua`; explore that file to learn about how the scripts work. A key feature is that many (eventually all) settings have a "full name" and a "short name", where the short name is used to override the default value when read from the commandline. For example, `settings.path.basename` determines the basename of the output file, and is by default computed from the file's tags. But if `name` is set in a Demlo `-pre` script, that value is used instead.

Make sure to customize the default profile (`01-default.lua`) to your liking, for it determines the options from `globals` that get chosen by default. The other profiles are also completely free to change, delete, or add to.

## Usage

No special invocation of Demlo is required. When enabling or disabling functionality with the `-s` and `-r` options, bear in mind that some things will break if you `r`emove certain scripts—namely, `util`, `globals`, and at least one profile, i.e. one starting with `01`.

Pass options using a `-pre` script.
