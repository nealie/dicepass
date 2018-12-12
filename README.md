Dicepass
========

Dicepass is a simple passphrase generator using the
[Diceware][diceware] method written in [Nim][nim]

By default the [EFF][eff] large word list is used, but the
[Diceware][diceware] list may also be selected if shorter words are desired.

  [diceware]: http://world.std.com/~reinhold/diceware.html
  [eff]: https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases
  [nim]: https://nim-lang.org/

Usage
-----

Invoking `dicepass` with no options will simply generate a seven word
passphrase using the [EFF][eff] long word list. This assumes that the
required word list has already been downloaded to `~.dicepass`. If not
a helpful message will tell so and what to do:

```Unable to open ~/.dicepass/eff_large_wordlist.txt
You may need to fetch it with the --fetch option```

The command options are as follows:

  * -w=WORDS, --words=WORDS

    How many words to generate (default 7).

  * -e, --eff

    Use the EFF word list (default).

  -d, --diceware

    Use the Diceware word list.

  * -l=LIST, --list=LIST

    Specify the filename of a list to use.

  * -f, --fetch

    Fetch the required list. This only works for the EFF or Diceware lists.

  * --clean

    Delete any downloaded lists, along with the .dicepass directory.

  * -h, --help

    Display a help message and exit.

  * -v, --version

    Display the version number and exit.
