pyvroworkflow
=============

This directory contains a collection of executable 
Python sample scripts that operate on
VMware vRealize Orchestrator workflows.

Design Goals
------------

Each file is intended to be a self-contained command line
executable with no dependencies other than Python 2.7 and
the Requests module. As such the code is very
un-DRY (Don't Repeat Yourself). However, this directory is
packaged as a Python module, so you can import it and write
scripts that can call the functions in the samples.

Security
--------

These samples make requests with verify=False and bypass
SSL certificate verification. Don't do that in production.
Passwords can be passed on the command line, or if omitted,
you will be prompted.
