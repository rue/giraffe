 Giraffe
=========

Simple wiki engine and eventually issue tracker using Git for storage.

All the changes made to the codebase in this particular fork of
the original excellent idea and various people's previous work
are for the purpose of centralising the documentation for Rubinius.

As such, some behaviours may not suit all other use cases.


 Requirements
--------------

These are all available through Gems.

- git
- metaid
- mongrel (or something, see Sinatra's help.)
- rack
- rdiscount
- rubypants

Sinatra (the web framework) is included as a submodule. To set it
up, issue the following from the project root:

    $ git submodule init
    $ git submodule update


 Features
----------

- Uses Git as storage backend.
  - History
  - Diffs
  - Searching
- Allows exposing only a subdirectory of the Git repository.
  - Serve directly from $PROJECT/doc without exporting or submodules.
- Minimal configuration.
- User authentication through HTTP basic. (See Configuration.)
- Restrict pages to files with a given extension.
- Pages may reside in subdirectories of the wiki root.


 Configuration
---------------

See doc/config.yml.sample for information. The configuration
file to be used can be given using the `-f` option.


 Running
---------

Run at port 8080:

    $ bin/giraffe -f config.yml -p 8080

Use production environment (development by default):

    $ bin/giraffe -f config.yml -e production

