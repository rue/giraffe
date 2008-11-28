 git-wiki
==========

Simple wiki engine that uses a Git repository as its data store.


 The rue Version of git-wiki
-----------------------------

All the changes made to the codebase in this particular fork of
the original excellent idea and various people's previous work
are for the purpose of centralising the documentation for Rubinius.

As such, some behaviours may not suit all other use cases.


 Requirements
--------------

These are all available through Gems.

- git
- metaid
- mongrel
- rack
- rdiscount
- rubypants

Sinatra (the web framework) is included as a submodule:

    $ cd $GITWIKIDIR
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


 Configuration
---------------

See config.yml.sample for information. The configuration
file to be used can be given using GITWIKI_CONF.


 Running
---------

Run at port 8080:

    $ ./bin/git-wiki.rb -p 8080

Use production environment (development by default):

    $ ./bin/git-wiki.rb -e production


