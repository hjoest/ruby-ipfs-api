require 'tmpdir'
require 'minitest/autorun'
begin
  Minitest.const_get('Test')
rescue
  module Minitest
    Test = Unit::TestCase
  end
end
if ENV['DEBUG']
  require 'byebug'
else
  def byebug; end
end

$:.unshift File.expand_path('../../lib', __FILE__)
require 'ipfs-api/upload'

module Samples

  TEMP_DIR_PREFIX = 'ruby-ipfs-api-unit-test-'

  include IPFS

  def some_virtual_folders
    fixture = [
      Upload.folder('a1') { |a1|
        a1.add_file('hello.txt') { |io|
          io.write "Hello World!\n"
        }
        a1.add_file('foo.txt') { |io|
          io.write "bar\n"
        }
      },
      Upload.folder('a2') { |a2|
        a2.add_file 'b1.txt', 'B1'
        a2.add_folder('b2') { |b2|
          b2.add_folder('c1') { |c1|
            c1.add_file 'd1.txt', 'D1'
          }
        }
        a2.add_file 'b3.txt', 'B3'
      },
      Upload.folder('a3') { |a3|
        a3.add_folder('b1') { |b1|
          b1.add_folder('c1') { |c1|
            c1.add_folder('d1') { |d1|
              d1.add_folder('e1') { |e1|
                e1.add_file('thanks.txt') { |io|
                  io.write 'This is the end.'
                }
              }
            }
          }
        }
      }
    ]
    expectation = {
      '/a1' => 'QmcsmfcY8SQzNxJQYGZMHLXCkeTgxDBhASDPJyVEGi8Wrv',
      '/a1/hello.txt' => 'QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG',
      '/a1/foo.txt' => 'QmTz3oc4gdpRMKP2sdGUPZTAGRngqjsi99BPoztyP53JMM',
      '/a2' => 'QmcfeG6dVvXufGXzxe6cBHP3ZbFx15yRzh7DSg8W67soto',
      '/a2/b1.txt' => 'QmSwyJZAaxRqo8v2itCErP8U4DKa3dkSu7qTpDF1qG64Vw',
      '/a2/b2' => 'QmQZ7ek8ss65DQFbCxXgFBzZeyJA6ZYJ9SfrTWZDSSQ2jj',
      '/a2/b2/c1' => 'QmU2K25J3hBJQeKuUTJeXpeCovev8Bp2m2FzFHU2ANznnE',
      '/a2/b2/c1/d1.txt' => 'QmNPDoyE8HaJWj7Bb7p2h3usA2nmbmUCx2712jXK2nftxz',
      '/a2/b3.txt' => 'QmdoSx7tA3ybphBXDR9TBNteYPHKKb8aySPLVStNkSaTy2',
      '/a3' => 'QmeQ7BYviWZynBhhzMCJVZRv5izgCFBfkGMU8fJJtzUA3f',
      '/a3/b1' => 'QmW7zVapNEqc7Gmhx6ZGkeNzgUMgcRxpjXkXSkWdoyUWd5',
      '/a3/b1/c1' => 'QmfHyLbTMjfUeD95wCmNNf4h5kJo3D65tEERs54zbRbWvv',
      '/a3/b1/c1/d1' => 'QmRMzLcUNFghRE9Cn62wBHThKJoS6ChjpgEmJwApJBPoVo',
      '/a3/b1/c1/d1/e1' => 'QmdJWhD7iU2kW5wTWP2hXoworetabt3n5tEtfEUyBoXCTv',
      '/a3/b1/c1/d1/e1/thanks.txt' => 'QmWu5tSQetrKPxhDff2AF8owzqcMreXdXqeVjr3LL4WyJX'
    }
    yield fixture, expectation
  end
  module_function :some_virtual_folders

  def some_filesystem_folders
    Dir.mktmpdir(TEMP_DIR_PREFIX) do |root|
      a1 = File.join(root, 'a1')
      Dir.mkdir(a1, 0755)
      b1 = File.join(a1, 'b1')
      Dir.mkdir(b1, 0755)
      hello = File.join(b1, 'hello.txt')
      File.open hello, 'w' do |fd|
        fd.write "Hello World!\n"
      end
      fixture = [ Dir.new(a1) ]
      expectation = {
        '/a1'=>'QmedYJNEKn656faSHaMv5UFVkgfSzwYf9u4zsYoXqgvnch',
        '/a1/b1' => 'QmSh4Xjoy16v6XmnREE1yCrPM1dnizZc2h6LfrqXsnbBV7',
        '/a1/b1/hello.txt' => 'QmfM2r8seH2GiRaC4esTjeraXEachRt8ZsSeGaWTPLyMoG'
      }
      yield fixture, expectation
    end
  end
  module_function :some_filesystem_folders

  def some_byte_sequences
    s = ('a'..'z').to_a.join
    [ s ] * 17
  end
  module_function :some_byte_sequences

end
