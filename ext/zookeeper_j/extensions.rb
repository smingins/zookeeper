module Zk

  Stat = com.yahoo.zookeeper.data.Stat
  class Stat
    def to_a
      [getCzxid, getMzxid, getCtime, getMtime, getVersion, getCversion, getAversion, getEphemeralOwner]
    end
  end

  Id = com.yahoo.zookeeper.data.Id

  ACL = com.yahoo.zookeeper.data.ACL
  class ACL
    
    def self.to_java(acl)
      ACL.new(acl.permissions, Id.new(acl.id.scheme, acl.id.identification))
    end
     
    def to_ruby
      ZooKeeper::ACL.new(self.getPerms, ZooKeeper::Id.new(self.getId.getScheme, self.getId.getId))
    end

  end
  
  class WatcherEvent < com.yahoo.zookeeper.proto.WatcherEvent; end
  
  module Watcher
    
    def self.extended(base)
      class << base
        alias_method :process_without_conv, :process
        alias_method :process, :process_with_conv
      end
    end
    
    def process_with_conv(event)
      process_without_conv(ZooKeeper::WatcherEvent.new(event.type, event.state, event.path))
    end
  end
  
  module AsyncCallback
    # you'd think this would work!!!   how do i refer to nested interface??
    # JavaUtilities.extend_proxy("com.yahoo.zookeeper.AsyncCallback.StringCallback") do
    #   alias process_result processResult
    # end
  
    module StringCallback
      def processResult(return_code, path, context, name)
        process_result(return_code, path, context, name)
      end
    end
  
    module VoidCallback
      def processResult(return_code, path, context)
        process_result(return_code, path, context)
      end
    end
  
    module StatCallback
      def processResult(return_code, path, context, stat)
        process_result(return_code, path, context, ZooKeeper::Stat.new(stat.to_a))
      end
    end
  
    module ChildrenCallback
      def processResult(return_code, path, context, children)
        process_result(return_code, path, context, children.to_a)
      end
    end
  
    module DataCallback
      def processResult(return_code, path, context, data, stat)
        process_result(return_code, path, context, String.from_java_bytes(data), ZooKeeper::Stat.new(stat.to_a))
      end
    end

    module AclCallback
      def processResult(return_code, path, context, acl, stat)
        process_result(return_code, path, context, acl.collect {|acl| acl.to_ruby}, ZooKeeper::Stat.new(stat.to_a))
      end
    end

  end
  
end

class NativeException
  
  def code
    cause.getCode rescue nil
  end
  
  def message
    cause.getMessage rescue nil
  end
  
end