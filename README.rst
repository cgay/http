**************
HTTP Libraries
**************

HTTP server, client, tests, and examples.  All required repositories
are included as submodules so if you clone with --recursive you should
have everything you need for building.

Build
=====

The easiest way to build everything except for the examples is::

  dylan-compiler -build http-test-suite

Test
====

Run all tests::

  $ dylan-compiler -build http-test-suite
  $ dylan-compiler -build testworks-run
  $ _build/bin/testworks-run --load libhttp-test-suite.so

Currently (Fall 2020) the tests hang.

Documentation
=============

Building the documentation requires that Python be able to find the
`Dylan extensions to Sphinx <https://github.com/dylan-lang/sphinx-extensions>`_.

The easiest way to do this is to check them out somewhere and put
them on your ``PYTHONPATH``::

    export PYTHONPATH=path/to/sphinx-extensions:$PYTHONPATH

You can clone sphinx-extensions with::

    git clone git@github.com:dylan-lang/sphinx-extensions
