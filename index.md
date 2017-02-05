# Overview

IPFS-API for Ruby is a client library to access the [Interplanetary Filesystem (IPFS)](https://ipfs.io) from Ruby.

You can find more examples in the
[examples directory](https://github.com/hjoest/ruby-ipfs-api/tree/master/examples).

## Installation

You need an [IPFS daemon](https://ipfs.io/docs/install/) running

    ipfs daemon

To install this gem, run

    gem install ipfs-api

or simply add this line to your ``Gemfile``

    gem 'ipfs-api', '~> 0.3.0'

## Basic examples

This example will add a directory to *IPFS*. The directory ``data``
must exist or otherwise an ``Errno::ENOENT`` error will be raised.

    require 'ipfs-api'

    ipfs = IPFS::Connection.new
    ipfs.add Dir.new('data')

Afterwards, we can retrieve what we put in.

    require 'ipfs-api'

    ipfs = IPFS::Connection.new

    # retrieve contents of a file
    print ipfs.cat('QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG')

    # retrieve the whole directory and make a copy of it in ``copy-of-data``
    ipfs.get('QmSh4Xjoy16v6XmnREE1yCrPM1dnizZc2h6LfrqXsnbBV7', 'copy-of-data')

## Advanced

Dynamically add folders and files to *IPFS*, without creating them
on the local file system:

    require 'ipfs-api'

    ipfs = IPFS::Connection.new
    folder = IPFS::Upload.folder('test') do |test|
      test.add_file('hello.txt') do |fd|
        fd.write 'Hello'
      end
      test.add_file('world.txt') do |fd|
        fd.write 'World'
      end
    end
    ipfs.add folder do |node|
      # display each uploaded node:
      print "#{node.name}: #{node.hash}\n" if node.finished?
    end

## License

This library is distributed under the [MIT License](https://github.com/hjoest/ruby-ipfs-api/tree/master/LICENSE).
