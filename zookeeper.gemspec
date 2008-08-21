def self.platform_files
  if defined?(JRUBY_VERSION)
    ["ext/zookeeper_j/log4j-1.2.15.jar", "ext/zookeeper_j/extensions.rb", "ext/zookeeper_j/zookeeper-dev.jar", "ext/zookeeper_j/zookeeper.rb"]
  else
    ["ext/zookeeper_c/zookeeper_ruby.c", "ext/zookeeper_c/zookeeper.rb"]
  end
end

def self.platform_extensions
  if defined?(JRUBY_VERSION)
    []
  else
    ["ext/zookeeper_c/extconf.rb"]
  end
end

Gem::Specification.new do |s|
  s.name = %q{zookeeper}
  s.version = "0.2"
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Mingins"]
  s.date = %q{2008-06-13}
  s.description = %q{A Ruby client interface to the Java ZooKeeper server.}
  s.email = %q{smingins@elctech.com}
  s.extra_rdoc_files = ["README"]
  s.extensions = platform_extensions
  s.files = ["README", "lib/zookeeper.rb", "lib/zookeeper/acl.rb", "lib/zookeeper/id.rb", "lib/zookeeper/keeper_exception.rb", "lib/zookeeper/permission.rb", "lib/zookeeper/stat.rb", "lib/zookeeper/watcher_event.rb"] + platform_files
  s.has_rdoc = true
  s.homepage = %q{ http://github.com/smingins/zookeeper/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "ZooKeeper", "--main", "README"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.1.0}
  s.summary =  %q{A Ruby client interface to the Java ZooKeeper server.}
end

