require File.join(File.dirname(__FILE__), %w[spec_helper])

describe ZooKeeper, "with no paths" do

  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end

  it "should not exist" do
    @zk.exists("/test").should be_nil
  end

  it "should create a path" do
    @zk.create(:path => "/test", :data => "test_data").should == "/test"
  end
  
  it "should raise an exception for a non existent path" do
    lambda { @zk.get("/non_existent_path") }.should raise_error(KeeperException::NoNode)
  end
  
  it "should create a path with sequence set" do
    @zk.create(:path => "/test", :data => "test_data", :sequence => true).should == "/test0"
  end
  
  it "should create an ephemeral path" do
    @zk.create(:path => "/test", :data => "test_data", :ephemeral => true).should == "/test"
  end
  
  it "should remove ephemeral path when client session ends" do
    pending('close Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk.create(:path => "/test", :data => "test_data", :ephemeral => true).should == "/test"
    @zk.exists("/test").should_not be_nil
    @zk.close
  
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    @zk.exists("/test").should be_nil
  end
  
  it "should remove sequential ephemeral path when client session ends" do
    pending('close Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk.create(:path => "/test", :data => "test_data", :ephemeral => true, :sequence => true).should == "/test0"
    @zk.exists("/test0").should_not be_nil
    @zk.close
  
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    @zk.exists("/test0").should be_nil
  end
  
  it "should asynchronously create a path and execute callback on callback object" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockStringCallback.new
    context = Time.new
    @zk.create(:path => "/test", :data => "test_data", :callback => callback, :context => context)
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.name.should        == "/test"
  end

end

describe ZooKeeper, "with a path" do
  
  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
    @zk.create(:path => "/test", :data => "test_data")
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end
  
  it "should return a stat" do
    @zk.exists("/test").should be_instance_of(ZooKeeper::Stat)
  end
  
  it "should get data and stat" do
    data, stat = @zk.get(:path => "/test", :stat => stat)
    data.should == "test_data"
    stat.should be_a_kind_of(ZooKeeper::Stat)
    stat.created_time.should_not == 0
  end
  
  it "should set data" do
    @zk.set(:path => "/test", :data => "foo")
    @zk.get("/test").first.should == "foo"
  end
  
  it "should set data with a file" do
    file = File.read('spec/test_file.txt')
    @zk.set(:path => "/test", :data => file)
    @zk.get("/test").first.should == file
  end
  
  it "should delete path" do
    @zk.delete("/test")
    @zk.exists("/test").should be_nil
  end
  
  it "should create a child path" do
    @zk.create(:path => "/test/child", :data => "child").should == "/test/child"
  end
  
  it "should create sequential child paths" do
    @zk.create(:path => "/test/child", :data => "child1", :sequence => true).should == "/test/child0"
    @zk.create(:path => "/test/child", :data => "child2", :sequence => true).should == "/test/child1"
    @zk.children("/test").should eql(["child0", "child1"])
  end
  
  it "should have no children" do
    @zk.children("/test").should be_empty
  end

  it "should asynchronously delete a path and execute callback" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockVoidCallback.new
    context = Time.new
    @zk.delete(:path => "/test", :callback => callback, :context => context)
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
  end
  
  it "should asynchronously do an exists and execute callback" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockStatCallback.new
    context = Time.new
    @zk.exists(:path => "/test", :callback => callback, :context => context)
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.stat.should be_a_kind_of(ZooKeeper::Stat)
  end

  it "should asynchronously set data and execute callback" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockStatCallback.new
    context = Time.new
    @zk.set(:path => "/test", :data => "foo", :callback => callback, :context => context)
    @zk.get("/test").first.should == "foo"
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.stat.should be_a_kind_of(ZooKeeper::Stat)
  end
  
  it "should asynchronously get data and execute callback" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockDataCallback.new
    context = Time.new
    @zk.get(:path => "/test", :callback => callback, :context => context).should be_nil
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.data.should == "test_data"
    callback.stat.should be_a_kind_of(ZooKeeper::Stat)
  end
  
end

describe ZooKeeper, "with children" do

  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
    @zk.create(:path => "/test", :data => "test_data")
    @zk.create(:path => "/test/child", :data => "child").should == "/test/child"
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end
  
  it "should get children" do
    @zk.children("/test").should eql(["child"])
  end
  
  it "should asynchronously get children and execute callback" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockChildrenCallback.new
    context = Time.new
    @zk.children(:path => "/test", :callback => callback, :context => context).should be_nil
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.children.should eql(["child"])
  end
  
end

describe ZooKeeper, "asynchronous create with no paths" do
  
  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
    @completed  = false
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end
  
  def completed?
    return @completed
  end
  
  def process_result(return_code, path, context, name)
    @return_code, @path, @context, @name = return_code, path, context, name
    @completed = true
  end

  it "should create a path and execute callback on self" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    context = Time.new
    @zk.create(:path => "/test", :data => "test_data", :callback => self, :context => context)
    wait_until { completed? }
    @return_code.should == 0
    @path.should        == "/test"
    @context.should     == context
    @name.should        == "/test"
  end

  it "should asynchronously create a path and execute callback on proc" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = proc do |return_code, path, context, name|
      self.instance_variable_set("@return_code", return_code)
      self.instance_variable_set("@path", path)
      self.instance_variable_set("@context", context)
      self.instance_variable_set("@name", name)
      self.instance_variable_set("@completed", true)
    end

    context = Time.new
    @zk.create(:path => "/test", :data => "test_data", :callback => callback, :context => context)
    wait_until { completed? }
    @return_code.should == 0
    @path.should        == "/test"
    @context.should     == context
    @name.should        == "/test"
  end

end

describe ZooKeeper, "watches" do
  
  before(:each) do
    @watcher = mock("Watcher")
    @watcher.stub!(:process)
    @watcher = EventWatcher.new

    @zk1 = ZooKeeper.new(:host => "localhost:2181", :watcher => @watcher)
    @zk2 = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk1.connected? && @zk2.connected? }
    @zk1.create(:path => "/test", :data => "test_data")
  end

  after(:each) do
    @zk1.close
    @zk2.close
    wait_until{ @zk1.closed? && @zk2.closed? }
  end
  
  it "should get data changed event" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.get(:path => "/test", :watch => true)
    @zk2.set(:path => "/test", :data => "foo")
    wait_until { @watcher.received_disconnected }
    @watcher.event_types.should include(ZooKeeper::WatcherEvent::EventNodeDataChanged)
  end
  
  it "should get an event when a path is created" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.exists(:path => "/fred", :watch => true)
    @zk2.create(:path => "/fred", :data => "freds_data").should == "/fred"
    wait_until { @watcher.received_disconnected }
    @watcher.event_types.should include(ZooKeeper::WatcherEvent::EventNodeCreated)
  end
  
  it "should get an event when a path is deleted" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.exists(:path => "/test", :watch => true)
    @zk2.delete(:path => "/test")
    wait_until { @watcher.received_disconnected }
    @watcher.event_types.should include(ZooKeeper::WatcherEvent::EventNodeDeleted)
  end
  
  it "should get an event when a child is added" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.children(:path => "/test", :watch => true)
    @zk2.create(:path => "/test/child", :data => "child1", :sequence => true, :empheral => true).should == "/test/child0"
    wait_until { @watcher.received_disconnected }
    @watcher.event_types.should include(ZooKeeper::WatcherEvent::EventNodeChildrenChanged)
  end

end

describe ZooKeeper, "versioning data" do

  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
    @zk.create(:path => "/test", :data => "test_data")
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end

  it "should allow setting data with a version" do
    @zk.set(:path => "/test", :data => "test_data_1", :version => 0)
    @zk.get(:path => "/test", :version => 0).first.should == "test_data_1"
  end

  it "should increment version when setting data" do
    @zk.set(:path => "/test", :data => "test_data_1")
    @zk.get(:path => "/test", :version => 1).first.should == "test_data_1"
  end
  
  it "should delete path with a version" do
    @zk.delete(:path => "/test", :version => 0)
    @zk.exists("/test").should be_nil
  end

end

describe ZooKeeper, "stats" do

  before(:each) do
    @zk = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk.connected? }
    @zk.create(:path => "/test", :data => "test_data")
    @zk.set(:path => "/test", :data => "test_data_1")
  end
  
  after(:each) do
    @zk.close
    wait_until{ @zk.closed? }
  end

  it "should return stat with exists" do
    stat = @zk.exists("/test")
    stat.should_not be_nil
    stat.should be_a_kind_of(ZooKeeper::Stat)

    stat.created_zxid.should       == 2
    stat.last_modified_zxid.should == 3

    stat.created_time.should        > 0
    stat.last_modified_time.should  > 0
    stat.last_modified_time.should  > stat.created_time

    stat.version.should            == 1
    stat.child_list_version.should == 0
    stat.acl_list_version.should   == 0
    stat.ephemeral_owner.should    == 0
  end

end

describe ZooKeeper, "ACL" do

  before(:each) do
    @zk1 = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    @zk2 = ZooKeeper.new(:host => "localhost:2181", :watcher => SilentWatcher.new)
    wait_until{ @zk1.connected? && @zk2.connected? }
  end
  
  after(:each) do
    @zk1.close
    @zk2.close
    wait_until{ @zk1.closed? && @zk2.closed? }
  end

  it "should create a path with OPEN_ACL_UNSAFE permissions by default" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.create(:path => "/test", :data => "test_data")
    @zk1.acls("/test").first.should == ZooKeeper::ACL::OPEN_ACL_UNSAFE
  end
  
  it "should create a path with READ_ACL_UNSAFE permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::READ_ACL_UNSAFE)
    @zk1.acls("/test").first.should == ZooKeeper::ACL::READ_ACL_UNSAFE
  end
  
  it "should get acl info asynchronously" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    callback = MockAclCallback.new
    context = Time.new
    @zk1.create(:path => "/test", :data => "test_data")
    @zk1.acls(:path => "/test", :callback => callback, :context => context)
    wait_until { callback.process_result_completed? }
    callback.return_code.should == 0
    callback.path.should        == "/test"
    callback.context.should     == context
    callback.acl.should         == ZooKeeper::ACL::OPEN_ACL_UNSAFE
  end
  
  it "should create a path with CREATOR_ALL_ACL permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.add_auth_info(:scheme => "digest", :auth => "shane:password")
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::CREATOR_ALL_ACL)
    @zk1.acls("/test").first.should == [ZooKeeper::ACL.new(ZooKeeper::Permission::ALL | ZooKeeper::Permission::ADMIN, 
                                        ZooKeeper::Id.new('digest', 'shane:pgPxAF2N8U79uqcuGPQx3C6J2c8='))]  
  end
  
  it "should set creator to read with CREATOR_ALL_ACL permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.add_auth_info(:scheme => "digest", :auth => "shane:password")
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::CREATOR_ALL_ACL)
    @zk2.add_auth_info(:scheme => "digest", :auth => "shane:password")
    @zk2.get("/test").first.should == "test_data"
  end
  
  it "should create node with CREATOR_ALL_ACL permissions if no authentcated ids present" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    lambda { @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::CREATOR_ALL_ACL) }.should raise_error(KeeperException::InvalidACL)
  end
  
  it "should not allow world to read node with CREATOR_ALL_ACL permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.add_auth_info(:scheme => "digest", :auth => "shane:password")
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::CREATOR_ALL_ACL)
    lambda { @zk2.get("/test") }.should raise_error(KeeperException::NoAuth)
  end

  it "should allow world to read with READ_ACL_UNSAFE permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::READ_ACL_UNSAFE)
    @zk2.get("/test").first.should == "test_data"
  end

  it "should not allow world to write with READ_ACL_UNSAFE permissions" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.create(:path => "/test", :data => "test_data", :acl => ZooKeeper::ACL::READ_ACL_UNSAFE)
    lambda { @zk2.set(:path => "/test", :data => "new_data") }.should raise_error(KeeperException::NoAuth)
  end
  
  it "should accept new ACL" do
    pending('Not implemented in MRI version yet') unless defined?(JRUBY_VERSION)
    @zk1.create(:path => "/test", :data => "test_data")
    lambda { @zk1.set_acl(:path => "/test", :acl =>  ZooKeeper::ACL::OPEN_ACL_UNSAFE) }.should_not raise_error(KeeperException::InvalidACL)
  end
  
end
