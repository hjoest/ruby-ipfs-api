$:.unshift File.expand_path('..', __FILE__)

require 'samples'
require 'ipfs-api'

include IPFS

class CommandLsTest < Minitest::Test

  def test_ls
    ipfs = Connection.new
    Samples.some_virtual_folders do |fixture, expectation|
      ipfs.add fixture
      actual = ipfs.ls('QmcsmfcY8SQzNxJQYGZMHLXCkeTgxDBhASDPJyVEGi8Wrv')
      expectation = {
        'Objects' => [
          {
            'Hash' => 'QmcsmfcY8SQzNxJQYGZMHLXCkeTgxDBhASDPJyVEGi8Wrv',
            'Links' => [
              {
                'Name' => 'foo.txt',
                'Hash' => 'QmTz3oc4gdpRMKP2sdGUPZTAGRngqjsi99BPoztyP53JMM',
                'Size' => 12,
                'Type' => 2
              },
              {
                'Name' => 'hello.txt',
                'Hash' => 'QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG',
                'Size' => 21,
                'Type' => 2
              }
            ]
          }
        ]
      }
      assert_equal expectation, actual
    end
  end

end
