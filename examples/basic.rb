require 'ipfs-api'

ipfs = IPFS::Connection.new

# add a directory
ipfs.add Dir.new('data')

# retrieve contents of a file
print ipfs.cat('QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG')

# retrieve the whole directory
ipfs.get('QmSh4Xjoy16v6XmnREE1yCrPM1dnizZc2h6LfrqXsnbBV7', 'copy-of-data')
