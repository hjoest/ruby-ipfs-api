require 'ipfs4r'

ipfs = IPFS::Connection.new
ipfs.add Dir.new('data')
