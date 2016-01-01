require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems/package_task'

$:.unshift 'lib'
require 'ipfs-api/version'

PKG_NAME = 'ipfs-api'
PKG_VERSION = IPFS::VERSION
AUTHORS = ['Holger Joest']
EMAIL = 'holger@joest.org'
HOMEPAGE = 'http://hjoest.github.io/ruby-ipfs-api'
SUMMARY = 'Interplanetary File System for Ruby'
DESCRIPTION = 'This is a client library to access the IPFS from Ruby'
RDOC_OPTIONS = [ '--title', SUMMARY, '--quiet', '--main', 'lib/ipfs-api.rb' ]
BUILD_FILES = [ 'Rakefile', 'ipfs-api.gemspec' ].sort
RDOC_FILES = [ 'README.md', 'LICENSE' ].sort
PKG_FILES = (BUILD_FILES + RDOC_FILES + Dir['{lib,test,examples}/**/*']).reject { |f| File.directory?(f) }.sort

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = ['test/test_*.rb']
end

RDoc::Task.new do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.rdoc_files.include(RDOC_FILES, "lib/**/*.rb")
  rd.options = RDOC_OPTIONS
end

CLEAN.include [ "*.gem*", "pkg", "rdoc", "test/tmp" ]

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.authors = AUTHORS
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.rubyforge_project = PKG_NAME
  s.summary = SUMMARY
  s.description = DESCRIPTION
  s.platform = Gem::Platform::RUBY
  s.licenses = ["MIT"]
  s.require_path = 'lib'
  s.executables = []
  s.files = PKG_FILES
  s.test_files = []
  s.has_rdoc = true
  s.extra_rdoc_files = RDOC_FILES
  s.rdoc_options = RDOC_OPTIONS
  s.required_ruby_version = ">= 1.9.3"
end

# also keep the gemspec up to date each time we package a tarball or gem
task :package => ['gem:update_gemspec']
task :gem => ['gem:update_gemspec']

Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_tar = true
  pkg.need_zip = true
end

namespace :gem do

  # thanks to the Merb project for this code.
  desc "Update Github Gemspec"
  task :update_gemspec do
    skip_fields = %w(new_platform original_platform date cache_dir cache_file loaded)

    result = "# WARNING : RAKE AUTO-GENERATED FILE.  DO NOT MANUALLY EDIT!\n"
    result << "# RUN : 'rake gem:update_gemspec'\n\n"
    result << "Gem::Specification.new do |s|\n"
    spec.instance_variables.sort.each do |ivar|
      value = spec.instance_variable_get(ivar)
      name  = ivar.to_s.split("@").last
      next if skip_fields.include?(name) || value.nil? || value == "" || (value.respond_to?(:empty?) && value.empty?)
      if name == "dependencies"
        value.each do |d|
          dep, *ver = d.to_s.split(" ")
          result <<  "  s.add_dependency #{dep.inspect}, #{ver.join(" ").inspect.gsub(/[()]/, "")}\n"
        end
      else
        case value
        when Array
          value =  name != "files" ? value.inspect : value.sort.uniq.inspect.split(",").join(",\n")
        when String, Fixnum, true, false
          value = value.inspect
        else
          value = value.to_s.inspect
        end
        result << "  s.#{name} = #{value}\n"
      end
    end
    result << "end"
    File.open(File.join(File.dirname(__FILE__), "#{spec.name}.gemspec"), "w"){|f| f << result}
  end

end
