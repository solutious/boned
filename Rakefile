require "rubygems"
require "rake"
require "rake/clean"
require 'yaml'

begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end
 
config = YAML.load_file("VERSION.yml")
task :default => ["build"]
CLEAN.include [ 'pkg', 'doc' ]
name = "boned"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.version = "#{config[:MAJOR]}.#{config[:MINOR]}.#{config[:PATCH]}"
    gem.name = name
    gem.rubyforge_project = gem.name
    gem.summary = "HTTP server companion for Bone (remote environment variables)"
    gem.description = gem.summary
    gem.email = "delano@solutious.com"
    gem.homepage = "https://github.com/solutious/boned"
    gem.authors = ["Delano Mandelbaum"]
    gem.add_dependency("bone",            ">= 0.3.0")
    gem.add_dependency("sinatra",         ">= 1.0.0")
    gem.add_dependency("thin")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


Rake::RDocTask.new do |rdoc|
  version = "#{config[:MAJOR]}.#{config[:MINOR]}.#{config[:PATCH]}.#{config[:BUILD]}"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "#{name} #{version}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("LICENSE.txt")
  rdoc.rdoc_files.include("bin/*.rb")
  rdoc.rdoc_files.include("lib/**/*.rb")
end


# Rubyforge Release / Publish Tasks ==================================

#about 'Publish website to rubyforge'
task 'publish:rdoc' => 'doc/index.html' do
  #sh "scp -rp doc/* rubyforge.org:/var/www/gforge-projects/#{name}/"
end

#about 'Public release to rubyforge'
task 'publish:gem' => [:package] do |t|
  sh <<-end
    rubyforge add_release -o Any -a CHANGES.txt -f -n README.md #{name} #{name} #{@spec.version} pkg/#{name}-#{@spec.version}.gem &&
    rubyforge add_file -o Any -a CHANGES.txt -f -n README.md #{name} #{name} #{@spec.version} pkg/#{name}-#{@spec.version}.tgz 
  end
end




