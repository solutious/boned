@spec = Gem::Specification.new do |s|
  s.name = "boned"
  s.rubyforge_project = 'boned'
  s.version = "0.2.1"
  s.summary = "The bone daemon"
  s.description = s.summary
  s.author = "Delano Mandelbaum"
  s.email = "delano@solutious.com"
  s.homepage = ""
  
  s.extra_rdoc_files = %w[README.md LICENSE.txt CHANGES.txt]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.md"]
  s.require_paths = %w[lib]
  
  s.executables = %w[boned]
  
  # = MANIFEST =
  # git ls-files
  s.files = %w(
  CHANGES.txt
  LICENSE.txt
  README.md
  Rakefile
  api/api-set.rb
  api/api.rb
  bin/boned
  boned.gemspec
  config.ru
  lib/boned.rb
  lib/boned/api.rb
  lib/boned/api/debug.rb
  lib/boned/api/redis.rb
  lib/boned/api/service.rb
  lib/boned/cli.rb
  lib/boned/models.rb
  lib/boned/models/bone.rb
  lib/boned/server.rb
  public/index.html
  try/10_bone_model.rb
  views/redisviewer/keys.erb
  )

  
end
