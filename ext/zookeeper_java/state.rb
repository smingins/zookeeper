class ZooKeeper
# from com.yahoo.zookeeper.Watcher.Event  
  CONNECTION_STATES = {
    -112 => "KeeperStateExpired",
    -1   => "KeeperStateUnknown",
     0   => "KeeperStateDisconnected",
     1   => "KeeperStateNoSyncConnected",
     3   => "KeeperStateSyncConnected",
     4   => "EventNodeChildrenChanged"
  }
  # final public static int KeeperStateChanged = 0;   WTF??????  TODO resolve this
  
  module State
    KeeperStateDisconnected  = 0
    KeeperStateSyncConnected = 3
  end
  
end