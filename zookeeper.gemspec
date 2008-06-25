Gem::Specification.new do |s|
  s.name = %q{zookeeper}
  s.version = "0.1"
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Mingins"]
  s.date = %q{2008-06-13}
  s.description = %q{A JRuby interface to the Java ZooKeeper server.}
  s.email = %q{smingins@elctech.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "spec/queue_spec.rb", "spec/queue_test.rb", "spec/spec_helper.rb", "spec/test_file.txt", "spec/zookeeper_exception_matcher.rb", "spec/zookeeper_spec.rb", "spec/zookeeper_test_server.rb", "lib/zookeeper", "lib/zookeeper/logging.rb", "lib/zookeeper/queue.rb", "lib/zookeeper/sync_primitive.rb", "lib/zookeeper.rb", "ext/zookeeper_java", "ext/zookeeper_java/acl.rb", "ext/zookeeper_java/async_callback.rb", "ext/zookeeper_java/create_flag.rb", "ext/zookeeper_java/default_watcher.rb", "ext/zookeeper_java/event.rb", "ext/zookeeper_java/id.rb", "ext/zookeeper_java/java.rb", "ext/zookeeper_java/keeper_exception.rb", "ext/zookeeper_java/log4j-1.2.15.jar", "ext/zookeeper_java/log4j-LICENSE", "ext/zookeeper_java/log4j-NOTICE", "ext/zookeeper_java/permission.rb", "ext/zookeeper_java/stat.rb", "ext/zookeeper_java/state.rb", "ext/zookeeper_java/watcher_event.rb", "ext/zookeeper_java/zookeeper-dev.jar", "ext/zookeeper_java/zookeeper.rb"]
  s.has_rdoc = true
  s.homepage = %q{ http://github.com/smingins/zookeeper/tree/master}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "ZooKeeper", "--main", "README"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{zookeeper}
  s.rubygems_version = %q{1.1.0}
  s.summary =  %q{A JRuby interface to the Java ZooKeeper server.}
end
