class ZooKeeper
  KeeperException = com.yahoo.zookeeper.KeeperException
  class KeeperException
  end
end

class NativeException
  
  def code
    cause.getCode rescue nil
  end
  
end