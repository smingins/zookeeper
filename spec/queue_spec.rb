require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Queue do
  
  before(:each) do
    @queue = ZooKeeper::Queue.new("localhost:2181", "/queue1")  
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @queue.active? && @zk.connected? }
  end
  
  after(:each) do
    @queue.stop
    @zk.close
    wait_until{ @queue.stopped? && @zk.closed? }
  end
  
  it "should have created a queue path" do
    @zk.exists(:path => "/queue1").should_not be_nil
  end
  
  it "should be empty" do
    @queue.should be_empty
  end
  
  it "should return true after successful produce" do
    @queue.produce("1").should be_true
    @queue.should_not be_empty
  end
  
  it "should produce 5 items" do
    5.times { |i| @queue.produce(i.to_s) }
    @zk.children(:path => "/queue1").size.should == 5
    @queue.should_not be_empty
  end
  
  it "should consume from a populated queue" do
    5.times { |i| @queue.produce(i.to_s) }
    @queue.consume
    @zk.children(:path => "/queue1").size.should == 4
  end
  
  
end
