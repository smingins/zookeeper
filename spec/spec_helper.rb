$LOAD_PATH << "#{File.dirname(__FILE__)}/../ext" << "#{File.dirname(__FILE__)}/../lib"

require 'rubygems'
require 'spec'
require 'zookeeper' 
require 'spec/zookeeper_test_server'
require 'spec/zookeeper_exception_matcher' 


# include extra java packages for zookeeper test server
module Java
  include_package "com.yahoo.zookeeper.server"
  include_package "org.apache.log4j"
end

Spec::Runner.configure do |config|
  config.include(ZooKeeperExceptionhMaker) 

  config.before(:each) do  
    # set log4j level to OFF, WARN etc 
    Java::Logger.getRootLogger().set_level(Java::Level::OFF)
  end
  
end

# method to waith until block passed returns true .... may be a better way or place for this? 
def wait_until(&block)
  until yield do 
    #nothing  
  end
end

# silent watcher for testing
class SilentWatcher; def process(event); end; end
