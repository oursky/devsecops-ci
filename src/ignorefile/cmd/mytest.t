It prints a helpful help message.

  $ ./ignorefile.exe --help=plain
  NAME
         ignorefile - Enforce ignore patterns in ignore files
  
  SYNOPSIS
         ignorefile [OPTION]... [FILE]
  
  ARGUMENTS
         FILE
             The ignore file to check. Default to stdin if not provided
  
  OPTIONS
         --help[=FMT] (default=auto)
             Show this help in format FMT. The value FMT must be one of `auto',
             `pager', `groff' or `plain'. With `auto', the format is `pager` or
             `plain' whenever the TERM env var is `dumb' or undefined.
  
  EXIT STATUS
         ignorefile exits with the following status:
  
         0   No incidents were found
  
         1   Some incidents were found
  
         124 on command line parsing errors.
  
         125 on unexpected internal errors (bugs).
  

It reads from stdin if no argument is provided.

  $ ./ignorefile.exe <<EOF\
  > .git\
  > .svn\
  > *.gpg\
  > *.pfx\
  > *.pem\
  > *.cer\
  > *.cert\
  > *.p12\
  > *.p8\
  > *.key\
  > .env\
  > .env.*\
  > EOF
  - [E:E003] Missing ignore pattern `docker-compose.override.yml'
             File  : <stdin>
--> exit 1

It passes good file.

  $ ./ignorefile.exe good.ignore

It fails bad file.

  $ ./ignorefile.exe bad.ignore
  - [E:E003] Missing ignore pattern `*.cer'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.cert'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.gpg'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.key'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.p12'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.p8'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.pem'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `*.pfx'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `.env'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `.env.*'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `.git'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `.svn'
             File  : bad.ignore
  - [E:E003] Missing ignore pattern `docker-compose.override.yml'
             File  : bad.ignore
--> exit 1
