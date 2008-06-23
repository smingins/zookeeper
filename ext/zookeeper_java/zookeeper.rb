# Main class representing the Java ZooKeeper Class.  See JavaDoc for ZooKeeper to see further details of ZooKeeper API.
class ZooKeeper
  
  @zk = nil

  # Initialize a new ZooKeeper Client.  Can be initialized with a string of the hosts names (see :host argument) otherwise pass a hash with arguments set.
  # 
  # ==== Arguments
  # * <tt>:host</tt> -- string of comma separated ZooKeeper server host:port pairs e.g. "server1:3000, server2:3000"
  # * <tt>:timeout</tt> -- optional session timeout, if not passed default will be used
  # * <tt>:watcher</tt> -- optional object implementing Watcher interface otherwise DefaultWatcher is used
  # 
  # ==== Examples
  #   zk = ZooKeeper.new("localhost:2181")
  #   zk = ZooKeeper.new("localhost:2181,localhost:3000")
  #   zk = ZooKeeper.new(:host => "localhost:2181", :watcher => MyWatcher.new)
  #   zk = ZooKeeper.new(:host => "localhost:2181,localhost:3000", :timeout => 10000, :watcher => MyWatcher.new)
  def initialize(args)
    args  = {:host => args} unless args.is_a?(Hash)
    host    = args[:host]
    timeout = args[:timeout] || DEFAULTS[:timeout]
    watcher = args[:watcher] || DefaultWatcher.new
    @zk = Java::ZooKeeper.new(host, timeout, watcher)
  end
  
  def session_id
    @zk.getSessionId()
  end
  
  def session_password
    String.from_java_bytes @zk.getSessionPasswd()
  end
  
  # Return the data of the node of the given path.  Can optionally return the Stat for the node if a Stat object is passed in as an argument.
  # 
  # If the watch is true and the call is successfull (no exception is thrown), a watch will be left on the node with the given path. The watch will be triggered by a 
  # successful operation that sets data on the node, or deletes the node.
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if no node with the given path exists.
  # 
  # Can be called with just the path, otherwise a hash with the arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:watch</tt> -- defaults to false, set to true if you need to watch this node
  # * <tt>:stat</tt> -- defaults to nil, provide a Stat object that will be set with the Stat information of the node path
  # * <tt>:callback</tt> -- provide a AsyncCallback::DataCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # ===== get data for path
  #   zk.get_data("/path")
  #   
  # ===== get data for path and populate stat
  #   stat = ZooKeeper::Stat.new
  #   zk.get_data(:path => "/path", :stat => stat)
  #
  # ===== get data and set watch on node
  #   zk.get_data(:path => "/path", :watch => true)
  #
  # ===== get data asynchronously
  #
  #   class DataCallback
  #     def process_result(return_code, path, context, data, stat)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = DataCallback.new
  #   context = Object.new
  #   zk.get_data(:path => "/path", :callback => callback, :context => context)
  def get_data(args)
    args  = {:path => args} unless args.is_a?(Hash)
    path     = args[:path]
    watch    = args[:watch] || false
    stat     = args[:stat]  || nil
    callback = args[:callback]
    context  = args[:context]

    if callback
      callback.extend AsyncCallback::DataCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.getData(path, watch, callback, context)
    else
      String.from_java_bytes @zk.getData(path, watch, stat)
    end
  end
  
  # Set the data for the node of the given path if such a node exists and the given version matches the version of the node (if the given version is -1, it matches any 
  # node's versions). Return the stat of the node.
  # 
  # This operation, if successful, will trigger all the watches on the node of the given path left by get_data calls.
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if no node with the given path exists. A KeeperException with error code 
  # KeeperException::Code::BadVersion will be thrown if the given version does not match the node's version.  
  #
  # Called with a hash of arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:data</tt> -- data to set
  # * <tt>:version</tt> -- defaults to -1, otherwise set to the expected matching version
  # * <tt>:callback</tt> -- provide a AsyncCallback::StatCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  #   zk.set_data(:path => "/path", :data => "foo")
  #   zk.set_data(:path => "/path", :data => "foo", :version => 0)
  #
  # ===== set data asynchronously
  #
  #   class StatCallback
  #     def process_result(return_code, path, context, stat)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = StatCallback.new
  #   context = Object.new
  #
  #   zk.set_data(:path => "/path", :data => "foo", :callback => callback, :context => context)
  def set_data(args)
    path     = args[:path]
    data     = args[:data]
    version  = args[:version] || -1
    callback = args[:callback]
    context  = args[:context]
    
    if callback
      callback.extend AsyncCallback::StatCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.setData(path, data.to_java_bytes, version, callback, context)
    else
      @zk.setData(path, data.to_java_bytes, version)
    end
  end

  # Create a node with the given path. The node data will be the given data, and node acl will be the given acl.  The path is returned.
  # 
  # The ephemeral argument specifies whether the created node will be ephemeral or not.
  # 
  # An ephemeral node will be removed by the ZooKeeper automatically when the session associated with the creation of the node expires.
  # 
  # The sequence argument can also specify to create a sequential node. The actual path name of a sequential node will be the given path plus a suffix "_i" where i is the 
  # current sequential number of the node. Once such a node is created, the sequential number will be incremented by one.
  # 
  # If a node with the same actual path already exists in the ZooKeeper, a KeeperException with error code KeeperException::Code::NodeExists will be thrown. Note that since 
  # a different actual path is used for each invocation of creating sequential node with the same path argument, the call will never throw a NodeExists KeeperException.
  # 
  # If the parent node does not exist in the ZooKeeper, a KeeperException with error code KeeperException::Code::NoNode will be thrown.
  # 
  # An ephemeral node cannot have children. If the parent node of the given path is ephemeral, a KeeperException with error code KeeperException::Code::NoChildrenForEphemerals 
  # will be thrown.
  # 
  # This operation, if successful, will trigger all the watches left on the node of the given path by exists and get_data API calls, and the watches left on the parent node 
  # by get_children API calls.
  # 
  # If a node is created successfully, the ZooKeeper server will trigger the watches on the path left by exists calls, and the watches on the parent of the node by get_children calls.
  #
  # Called with a hash of arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:data</tt> -- initial data for the node
  # * <tt>:acl</tt> -- defaults to ACL::OPEN_ACL_UNSAFE, otherwise the ACL for the node
  # * <tt>:ephemeral</tt> -- defaults to false, if set to true the created node will be ephemeral
  # * <tt>:sequence</tt> -- defaults to false, if set to true the created node will be sequential
  # * <tt>:callback</tt> -- provide a AsyncCallback::StringCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # ===== create node, ACL will default to ACL::OPEN_ACL_UNSAFE
  #   zk.create(:path => "/path", :data => "foo")
  #   # => "/path"
  #
  # ===== create ephemeral node
  #   zk.create(:path => "/path", :data => "foo", :ephemeral => true)
  #   # => "/path"
  #
  # ===== create sequential node
  #   zk.create(:path => "/path", :data => "foo", :sequence => true)
  #   # => "/path0"
  #
  # ===== create ephemeral and sequential node
  #   zk.create(:path => "/path", :data => "foo", :ephemeral => true, :sequence => true)
  #   # => "/path0"
  #
  # ===== create a child path
  #   zk.create(:path => "/path/child", :data => "bar")
  #   # => "/path/child"
  #
  # ===== create a sequential child path
  #   zk.create(:path => "/path/child", :data => "bar", :sequence => true)
  #   # => "/path/child0"
  #
  # ===== create asynchronously with callback object
  #
  #   class StringCallback
  #     def process_result(return_code, path, context, name)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = StringCallback.new
  #   context = Object.new
  #
  #   zk.create(:path => "/path", :data => "foo", :callback => callback, :context => context)
  #
  # ===== create asynchronously with callback proc
  #
  #   callback = proc do |return_code, path, context, name|
  #       # do processing here
  #   end
  #
  #   context = Object.new
  #
  #   zk.create(:path => "/path", :data => "foo", :callback => callback, :context => context)
  #
  # 
  def create(args)
    path     = args[:path]
    data     = args[:data]
    acl      = args[:acl] || ACL::OPEN_ACL_UNSAFE
    flags    = 0
    flags    |= CreateFlag::EPHEMERAL if args[:ephemeral]
    flags    |= CreateFlag::SEQUENCE  if args[:sequence]
    callback = args[:callback]
    context  = args[:context]
    
    if callback
      callback.extend AsyncCallback::StringCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.create(path, data.to_java_bytes, acl, flags, callback, context)
    else
      @zk.create(path, data.to_java_bytes, acl, flags)
    end
  end

  # Delete the node with the given path. The call will succeed if such a node exists, and the given version matches the node's version (if the given version is -1, 
  # it matches any node's versions).
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if the nodes does not exist.
  # 
  # A KeeperException with error code KeeperException::Code::BadVersion will be thrown if the given version does not match the node's version.
  # 
  # A KeeperException with error code KeeperException::Code::NotEmpty will be thrown if the node has children.
  # 
  # This operation, if successful, will trigger all the watches on the node of the given path left by exists API calls, and the watches on the parent node left by 
  # get_children API calls.
  #
  # Can be called with just the path, otherwise a hash with the arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node to be deleted
  # * <tt>:version</tt> -- defaults to -1, otherwise set to the expected matching version
  # * <tt>:callback</tt> -- provide a AsyncCallback::VoidCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  #   zk.delete("/path")
  #   zk.delete(:path => "/path", :version => 0)
  #
  # ===== delete node asynchronously
  #
  #   class VoidCallback
  #     def process_result(return_code, path, context)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = VoidCallback.new
  #   context = Object.new
  #
  #   zk.delete(:path => "/path", :callback => callback, :context => context)
  def delete(args)
    args = {:path => args} unless args.is_a?(Hash)
    path     = args[:path]
    version  = args[:version] || -1
    callback = args[:callback]
    context  = args[:context]
    
    if callback
      callback.extend AsyncCallback::VoidCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.delete(path, version, callback, context)
    else
      @zk.delete(path, version)
    end
  end
  
  # Close this client object. Once the client is closed, its session becomes invalid. All the ephemeral nodes in the ZooKeeper server associated with the session 
  # will be removed. The watches left on those nodes (and on their parents) will be triggered.
  def close
    @zk.close
  end
  
  # Return the stat of the node of the given path. Return nil if no such a node exists.
  # 
  # If the watch is true and the call is successful (no exception is thrown), a watch will be left on the node with the given path. The watch will be triggered by 
  # a successful operation that creates/delete the node or sets the data on the node.
  #
  # Can be called with just the path, otherwise a hash with the arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:watch</tt> -- defaults to false, set to true if you need to watch this node
  # * <tt>:callback</tt> -- provide a AsyncCallback::StatCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # ===== exists for path
  #   zk.exists("/path")
  #   # => ZooKeeper::Stat
  #
  # ===== exists for path with watch set
  #   zk.exists(:path => "/path", :watch => true)
  #   # => ZooKeeper::Stat
  #
  # ===== exists for non existent path
  #   zk.exists("/non_existent_path")
  #   # => nil
  #
  # ===== exist node asynchronously
  #
  #   class StatCallback
  #     def process_result(return_code, path, context, stat)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = StatCallback.new
  #   context = Object.new
  #
  #   zk.exists(:path => "/path", :callback => callback, :context => context)
  def exists(args)
    args  = {:path => args} unless args.is_a?(Hash)
    path     = args[:path]
    watch    = args[:watch] || false
    callback = args[:callback]
    context  = args[:context]

    if callback
      callback.extend AsyncCallback::StatCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.exists(path, watch, callback, context)
    else
      @zk.exists(path, watch)
    end

  end

  # Return the list of the children of the node of the given path.
  # 
  # If the watch is true and the call is successful (no exception is thrown), a watch will be left on the node with the given path. The watch willbe triggered by a
  # successful operation that deletes the node of the given path or creates/delete a child under the node.
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if no node with the given path exists.
  # 
  # Can be called with just the path, otherwise a hash with the arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:watch</tt> -- defaults to false, set to true if you need to watch this node
  # * <tt>:callback</tt> -- provide a AsyncCallback::ChildrenCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # ===== get children for path
  #   zk.create(:path => "/path", :data => "foo")
  #   zk.create(:path => "/path/child", :data => "child1", :sequence => true)
  #   zk.create(:path => "/path/child", :data => "child2", :sequence => true)
  #   zk.get_children("/path")
  #   # => ["child0", "child1"]
  #
  # ====== get children and set watch
  #   zk.get_children(:path => "/path", :watch => true)
  #   # => ["child0", "child1"]
  #
  # ===== get children asynchronously
  #
  #   class ChildrenCallback
  #     def process_result(return_code, path, context, children)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = ChildrenCallback.new
  #   context = Object.new
  #   zk.get_children(:path => "/path", :callback => callback, :context => context)
  def get_children(args)
    args    = {:path => args} unless args.is_a?(Hash)
    path     = args[:path]
    watch    = args[:watch] || false
    callback = args[:callback]
    context  = args[:context]

    if callback
      callback.extend AsyncCallback::ChildrenCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.getChildren(path, watch, callback, context)
    else
      @zk.getChildren(path, watch).to_a
    end
  end

  # Return state of ZooKeeper client as a string.  Possible values are:
  # * ASSOCIATING
  # * AUTH_FAILED
  # * CLOSED
  # * CONNECTED
  # * CONNECTING
  def state
    @zk.getState.to_s
  end
  
  # Returns if ZooKeeper is in the connected state
  def connected?
    @zk.getState == Java::ZooKeeper::States::CONNECTED
  end

  # Returns if ZooKeeper is in the closed state
  def closed?
    @zk.getState == Java::ZooKeeper::States::CLOSED
  end
  
  # Return the ACL and stat of the node of the given path.
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if no node with the given path exists.  
  #
  # Can be called with just the path, otherwise a hash with the arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:stat</tt> -- defaults to nil, provide a Stat object that will be set with the Stat information of the node path
  # * <tt>:callback</tt> -- provide a AsyncCallback::AclCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # ===== get acl
  #   zk.get_acl("/path")
  #   # => [ACL]
  #
  # ===== get acl with stat
  #   stat = ZooKeeper::Stat.new
  #   zk.get_acl(:path => "/path", :stat => stat)
  #
  # ===== get acl asynchronously
  #
  #   class AclCallback
  #     def processResult(return_code, path, context, acl, stat)
  #       # do processing here
  #     end
  #   end
  #  
  #   callback = AclCallback.new
  #   context = Object.new
  #   zk.get_acl(:path => "/path", :callback => callback, :context => context)
  def get_acl(args)
    args  = {:path => args} unless args.is_a?(Hash)
    path     = args[:path]
    stat     = args[:stat]  || Stat.new
    callback = args[:callback]
    context  = args[:context]

    if callback
      callback.extend AsyncCallback::AclCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.getACL(path, stat, callback, context)
    else
      @zk.getACL(path, stat).to_a
    end
  end

  # Set the ACL for the node of the given path if such a node exists and the given version matches the version of the node. Return the stat of the node.
  # 
  # A KeeperException with error code KeeperException::Code::NoNode will be thrown if no node with the given path exists.
  # 
  # A KeeperException with error code KeeperException::Code::BadVersion will be thrown if the given version does not match the node's version.
  #
  # Called with a hash of arguments set.  Supports being executed asynchronousy by passing a callback object.
  # 
  # ==== Arguments
  # * <tt>:path</tt> -- path of the node
  # * <tt>:acl</tt> -- acl to set
  # * <tt>:version</tt> -- defaults to -1, otherwise set to the expected matching version
  # * <tt>:callback</tt> -- provide a AsyncCallback::StatCallback object or Proc for an asynchronous call to occur
  # * <tt>:context</tt> --  context object passed into callback method
  # 
  # ==== Examples
  # TBA - waiting on clarification of method use
  def set_acl(args)
    path     = args[:path]
    acl      = args[:acl]
    version  = args[:version] || -1
    callback = args[:callback]
    context  = args[:context]

    if callback
      callback.extend AsyncCallback::StatCallback unless callback.is_a?(Proc) || callback.respond_to?(:processResult)
      @zk.setACL(path, acl, version, callback, context)
    else
      @zk.setACL(path, acl, version)
    end
  end
  
  # Add authentication information.
  #
  # ZooKeeper has the following built in schemes:
  # 
  # * world has a single id, anyone, that represents anyone.
  # * auth doesn't use any id, represents any authenticated user.
  # * digest uses a _username:password_ string to generate MD5 hash which is then used as an ACL ID identity. Authentication is done by sending the _username:password_ in clear text. When used in the ACL the expression will be the _username:base64_encoded_SHA1_password_digest_.
  # * host uses the client host name as an ACL ID identity. The ACL expression is a hostname suffix. For example, the ACL expression _host:corp.com_ matches the ids _host:host1.corp.com_ and _host:host2.corp.com_, but not _host:host1.store.com_.
  # * ip uses the client host IP as an ACL ID identity. The ACL expression is of the form _addr/bits_ where the most significant _bits_ of _addr_ are matched against the most significant _bits_ of the client host IP.
  #
  # Called with a hash of arguments set
  # 
  # ==== Arguments
  # * <tt>:scheme</tt> -- scheme
  # * <tt>:auth</tt> -- authentication
  # 
  # ==== Examples
  #   zk.add_auth_info(:scheme => "digest", :auth => "ben:password")
  def add_auth_info(args)
    scheme = args[:scheme]
    auth   = args[:auth]
    @zk.addAuthInfo(scheme, auth.to_java_bytes)
  end
  
  # Returns string describing connection
  #
  # ==== Examples
  #   zk.connection
  #   #=> "sessionId: 79557110010085376\nlastZxid: 0\nxid: 1\nnextAddrToTry: 1\nserverAddrs: localhost/127.0.0.1:3000\n"
  def connection
    return @zk.describeCNXN()
  end
  
end