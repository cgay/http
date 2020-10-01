**************
HTTP Libraries
**************

HTTP server, client, tests, and examples.

Usage
=====

Install `dylan-tool <https://github.com/cgay/dylan-tool>`_ if you haven't
already.

1.  Create a new workspace with ``dylan-tool new my-workspace http`` and then
    ``cd my-workspace``.

3.  Run ``dylan-tool update`` to install dependencies and generate a registry.

4.  Build everything (except the examples) with ``dylan-compiler -build
    http-test-suite``.

5.  Optionally run all the tests::

      $ dylan-compiler -build testworks-run
      $ _build/bin/testworks-run --load libhttp-test-suite.so

    (Currently, as of Fall 2020, the tests hang. So there's that.)

Documentation
=============

Building the documentation requires that Python be able to find the
`Dylan extensions to Sphinx <https://github.com/dylan-lang/sphinx-extensions>`_.

The easiest way to do this is to check them out somewhere and put
them on your ``PYTHONPATH``::

    export PYTHONPATH=path/to/sphinx-extensions:$PYTHONPATH

You can clone sphinx-extensions with::

    git clone git@github.com:dylan-lang/sphinx-extensions
