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

- Store documentation in the repository and simultaneously
  make it available through a Wiki interface.
- Uses Git as storage backend.
  - History
  - Diffs
  - Searching
- Minimal configuration done in pure Ruby.
- Serve from repository root or any subdirectory.
- URI-to-file-to-URI mapping and file- and resource visibility mapping.
- User authentication through HTTP basic. (See Configuration.)
- Rack support.


 Configuration
---------------

Currently, you must have an existing Git repository (although
it may be empty--the .git/ stuff must exist.)

See doc/config.rb.sample for information. The configuration
file to be used can be given using the `-f` option. At a
minimum, you will probably give the path to your repository.

You can write a rackup file to serve the application. See
`config.ru` for an example.


 Running
---------

Run at port 8080:

    $ bin/giraffe -f config.rb -p 8080

Use production environment (development by default):

    $ bin/giraffe -f config.rb -e production -p 8080

If you are writing a rackup file, you presumably know
what you are doing :)

