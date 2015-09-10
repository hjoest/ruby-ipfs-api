# Overview

IPFS4R is a client library to access the [Interplanetary Filesystem (IPFS)](https://ipfs.io) from Ruby.

You can find more examples in the
[examples directory](https://github.com/hjoest/ipfs4r/tree/master/examples).

## Installation

Use ``gem`` to install it

```bash
gem install ipfs4r
```

or simply add this line to your ``Gemfile``

```ruby
gem 'ipfs4r', '~> 0.1.0'
```

## Basic examples

This example will add a directory to *IPFS*. The directory ``data``
must exist or otherwise an ``Errno::ENOENT`` error will be raised.

```ruby
require 'ipfs4r'

ipfs = IPFS::Connection.new
ipfs.add Dir.new('data')
```

## Advanced

Dynamically add folders and files to *IPFS*, without creating them
on the local file system:

```ruby
require 'ipfs4r'

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
```

## License

This library is distributed under the [MIT License](https://github.com/hjoest/ipfs4r/tree/master/LICENSE).
