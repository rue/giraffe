 Giraffe
=========

Simple wiki engine and eventually issue tracker using Git for storage.

All the changes made to the codebase in this particular fork of
the original excellent idea and various people's previous work
are for the purpose of centralising the documentation for Rubinius.

As such, some behaviours may not suit all other use cases.


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
- Run directly or with rackup.


 Requirements
--------------

Gems needed by Giraffe:

- rdiscount
- rubypants

Optionally:

- rspec
- nokogiri
- ruby-debug

The web framework used, Waves, is included as a submodule.
To set it up, issue the following from the project root:

    $ git submodule init
    $ git submodule update

Waves has quite a few dependencies, so it is best to use
its tools to install those. Once you have done the above:

    $ cd waves
    $ sudo rake setup

This installs the gems necessary.


 Configuration
---------------

Currently, you must have an existing Git repository (although
it may be empty--the .git/ stuff must exist.)

See doc/config.rb.sample for information. The configuration
file to be used can be given in the GIRAFFE_CONF environment
variable, but defaults to "config.rb".


 Specs
-------

There is a minimal amount of specs (please add some):

    $ spec -fs spec


 Running Standalone
--------------------

Without further configuration, Giraffe will run on Mongrel
at 0.0.0.0:8080:

    $ waves/bin/waves server --startup run_giraffe_run.rb

For options, see:

    $ waves/bin/waves server --help
    $ waves/bin/waves --help


 Running With rackup
---------------------

Your server software should have instructions on running rackup
applications. There is nothing special you need to do for Giraffe.

Note that config.ru /does/ assume you have a running server that
invokes rackup. If you want to run standalone, see instructions
above.

If you are writing a rackup file, you presumably know
what you are doing :)

