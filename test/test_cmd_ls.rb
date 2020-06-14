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
      actual = streamline_result(actual)
      expectation = {
        'Objects' => [
          {
            'Hash' => 'QmcsmfcY8SQzNxJQYGZMHLXCkeTgxDBhASDPJyVEGi8Wrv',
            'Links' => [
              {
                'Name' => 'foo.txt',
                'Hash' => 'QmTz3oc4gdpRMKP2sdGUPZTAGRngqjsi99BPoztyP53JMM',
                'Size' => 4,
                'Type' => 2
              },
              {
                'Name' => 'hello.txt',
                'Hash' => 'QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG',
                'Size' => 13,
                'Type' => 2
              }
            ]
          }
        ]
      }
      assert_equal expectation, actual
    end
  end

  # At some point, around version 0.4.2, a new property "Target" was introduced
  # to the "Links" objects. In order to match the test expectation, and still not
  # fail for older versions, we just remove these here whenever they're empty.
  private
  def streamline_result result
    result['Objects'].each do |object|
      object['Links'].each do |link|
        if link['Target'] == ''
          link.delete('Target')
        end
      end
    end
    result
  end

end
