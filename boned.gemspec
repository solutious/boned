@spec = Gem::Specification.new do |s|
  s.name = "boned"
  s.rubyforge_project = 'boned'
  s.version = "0.2.0"
  s.summary = "Get Bones"
  s.description = s.summary
  s.author = "Delano Mandelbaum"
  s.email = "delano@solutious.com"
  s.homepage = ""
  
  s.extra_rdoc_files = %w[README.md LICENSE.txt CHANGES.txt]
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--title", s.summary, "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  
  s.executables = %w[bone]
  
  # = MANIFEST =
  # git ls-files
  s.files = %w(
  LICENSE.txt
  README.md
  Rakefile
  bin/boned
  boned.gemspec
  config/redis-default.yml
  config/redis-server-default.conf
  config/stella/api-set.rb
  config/stella/api.rb
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
