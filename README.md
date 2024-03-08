# drin/hatchery

This is a repository of homebrew formula developed for my personal development. If they're
generally useful they can be upstreamed to be a homebrew formula, or maybe renamed to
signal they're preferred for general usage.


# Formulae

## Descriptions

As of now, the only formula in this tap is `apache-arrow-substrait` which is a variant of
[apache-arrow][formula-arrow] but with the substrait library enabled.

I will likely try to add other formula for other substrait integrations and such.

## Installation

To install a formula from this tap without tapping, run this command:

```bash
brew install drin/hatchery/<formula>
```

Otherwise, you can tap first:
```bash
brew tap drin/hatchery
```

then install the formula without specifying the tap:
```bash
brew install <formula>
```


# Documentation

For general homebrew documentation, check the [Homebrew website][web-brew], or run one of
the following commands:

```bash
# view homebrew's short help message
brew help

# view homebrew's (extensive) manpage
man brew
```


# Licensing

The homebrew is [licensed using the BSD 2-Clause License][misc-brew-license], so for
simplicity we use the same license for this repository. This is especially simple because
most formulae will initially be variants of core formulae.


<!-- resources -->
[web-brew]:          https://docs.brew.sh

[formula-arrow]:     https://github.com/Homebrew/homebrew-core/blob/master/Formula/a/apache-arrow.rb

[misc-brew-license]: https://github.com/Homebrew/homebrew-core/blob/master/LICENSE.txt
