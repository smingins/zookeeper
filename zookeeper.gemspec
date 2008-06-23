require 'rubygems'

PKG_FILES = %w(README Rakefile) +
      Dir.glob("{spec,lib}/**/*") + 
      Dir.glob("ext/**/*") 

SPEC = Gem::Specification.new do |s|
  s.name = %q{zookeeper}
  s.version = "0.1"
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Mingins"]
  s.date = %q{2008-06-13}
  s.description = %q{A JRuby interface to the Java ZooKeeper server.}
  s.email = %q{smingins@elctech.com}
  s.extra_rdoc_files = ["README"]
  s.files = PKG_FILES
  s.has_rdoc = true
  s.homepage = %q{ http://github.com/smingins/zookeeper/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "ZooKeeper", "--main", "README"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{zookeeper}
  s.rubygems_version = %q{1.1.0}
  s.summary =  %q{A JRuby interface to the Java ZooKeeper server.}
end

if $0 == __FILE__
  Gem::manage_gems
  Gem::Builder.new(SPEC).build
end