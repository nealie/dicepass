## Dicepass password generator.

# Copyright (c) 2018 Neal Nelson

import
  os,
  parseopt,
  math,
  strutils,
  ospaths,
  httpclient,
  streams,
  tables

const
  version = "1.0"
  listDir = "~/.dicepass"
  effList = "eff_large_wordlist.txt"
  effListUrl = "https://www.eff.org/files/2016/07/18/" & effList
  dicewareList = "diceware.wordlist.asc"
  dicewareListUrl = "https://world.std.com/~reinhold/" & dicewareList
  defaultNumWords = 7
  randomDevice = "/dev/urandom"

let name = extractFilename(getAppFilename())

proc showHelp() =
  ## Display command line help and exit.
  quit("""usage: $1 [options]
  
Diceware password generator v$2
  
Optional arguments:
  -h, --help                    Show this help message and exit
  -v, --version                 Show version number and exit
  
Password generation:
  -w=WORDS, --words=WORDS       How many words to generate (default 7)
  
List functions:
  -e, --eff                     Use the EFF word list (default)
  -d, --diceware                Use the Diceware word list
  -f, --fetch                   Fetch the required list
  -l=LIST, --list=LIST          Filename of a word list to use
  --clean                       Delete any downloaded lists""" % [name, version], QuitSuccess)

proc showVersion() =
  ## Display the version number and exit.
  quit("$1 v$2" % [name, version], QuitSuccess)

proc downloadList(url, filename: string) =
  ## Download the specified word list.
  var
    client = newHttpClient()
  echo("Downloading $#..." % url)
  client.downloadFile(url, filename)

proc readList(filename: string): Table[int, string] =
  ## Read the word list.
  var
    pgp = false
    line: string
    fields: seq[string]
    input = newFileStream(filename, fmRead)

  result = initTable[int, string]()

  if isNil(input):
    quit("Unable to open $#\nYou may need to fetch it with the --fetch option" % filename)

  while input.readLine(line):
    if line != "":
      if line[0] == '-':
        # Ignore PGP  encapsulation and exit after the second line
        # so that we don't read past the end of the list.
        if pgp: break
        pgp = true
      else:
        fields = line.strip().split()
        result[parseInt(fields[0])] = fields[1]
  input.close()

let listPathDir = expandTilde(listDir)
discard existsOrCreateDir(listPathDir)

var
  listPath = effList
  fetchList = false
  customList = false
  numWords = defaultNumWords

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    quit("No arguments supported: $#" % key, QuitFailure)
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      showHelp()
    of "version", "v":
      showVersion()
    of "words", "w":
      try:
        numWords = parseInt(val)
      except ValueError:
        quit("Number of words must be specified (-w=n or --words=n)", QuitFailure)
    of "eff", "e":
      listPath = effList
    of "diceware", "d":
      listPath = dicewareList
    of "list", "l":
      listPath = val
      customList = true
      if listPath == "":
        quit("No list file specified", QuitFailure)
      if not existsFile(listPath):
        quit("Specified list file does not exist", QuitFailure)
    of "fetch", "f":
      fetchList = true
    of "clean":
      removeDir(listPathDir)
      quit(QuitSuccess)
  of cmdEnd:
    assert(false)

if fetchList:
  if  listPath == effList:
    downloadList(effListUrl, listPathDir / listPath)
  elif listPath == dicewareList:
    downloadList(dicewareListUrl, listPathDir / listPath)
  else:
    quit("Unable to fetch list $#. Download location not known." % listPath, QuitFailure)

if not customList:
  listPath = listPathDir / listPath

var
  wordList = readList(listPath)
  passphrase = ""

var rfile: File

proc getRandom(): int =
  ## Read a random number from random device.
  if rfile.readBuffer(addr result, 1) <= 0:
    raise newException(OSError, "Can't read enough bytes from $#" % randomDevice)

proc rollDice(): int =
  ## Simulate rolling a dice five times.
  for index in 0..4:
    var roll = (getRandom() mod 6) + 1
    roll = roll * (10^index)
    result += roll

if not rfile.open(randomDevice):
  raise newException(OSError, "Can't open $#" % randomDevice)

for count in 1..numWords:
  stdout.write(wordList[rollDice()])
  stdout.write(" ")
stdout.write("\n")

rfile.close()
