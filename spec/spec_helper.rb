$LOAD_PATH << "#{File.dirname(__FILE__)}/../ext" << "#{File.dirname(__FILE__)}/../lib"
require 'zookeeper'
require 'spec/mock_callbacks'
require 'spec/zookeeper_test_server'


Spec::Runner.configure do |config|  
  config.before(:each) do
    ZooKeeperTestServer.start
    wait_until { ZooKeeperTestServer.running? }
  end

  config.after(:each) do
    ZooKeeperTestServer.stop
    wait_until { !ZooKeeperTestServer.running? }
  end
end

# method to waith until block passed returns true or timeout (default is 10 seconds) is reached 
def wait_until(timeout=10, &block)
  time_to_stop = Time.now + timeout
  until yield do 
    break unless Time.now < time_to_stop
  end
end

# silent watcher for testing
class SilentWatcher; def process(event); end; end

class EventWatcher
  
  attr_reader :events, :received_disconnected
  
  def initialize
    @received_disconnected = false
    @events = []
  end
  
  def process(event)
    @events << event
    @received_disconnected = event.state == ZooKeeper::WatcherEvent::KeeperStateDisconnected
  end
  
  def event_types
    @events.collect { |e| e.type }
  end
  
end
