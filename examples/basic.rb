require 'ipfs-api'

ipfs = IPFS::Connection.new
ipfs.add Dir.new('data')
