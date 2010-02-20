
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/runtest'
require 'fileutils'
include FileUtils

begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

task :default => :test


# PACKAGE =============================================================

name = "boned"
load "#{name}.gemspec"

version = @spec.version

Rake::GemPackageTask.new(@spec) do |p|
  p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end

task :test do
  puts "Success!"
end

task :install => [ :rdoc, :package ] do
	sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
	sh %{sudo gem uninstall #{name}}
end



Rake::RDocTask.new do |t|
	t.rdoc_dir = 'doc'
	t.title    = @spec.summary
	t.options << '--line-numbers' <<  '-A cattr_accessor=object'
	t.options << '--charset' << 'utf-8'
	t.rdoc_files.include('LICENSE.txt')
	t.rdoc_files.include('README.md')
	t.rdoc_files.include('CHANGES.txt')
	#t.rdoc_files.include('Rudyfile')  # why is the formatting f'd?
	t.rdoc_files.include('bin/*')
	t.rdoc_files.include('lib/**/*.rb')
end

CLEAN.include [ 'pkg', '*.gem', '.config', 'doc', 'coverage*' ]



