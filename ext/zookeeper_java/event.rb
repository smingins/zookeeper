class ZooKeeper
  # from com.yahoo.zookeeper.Watcher.Event
  EVENT_TYPES = {
    -1 => "EventNone",
     1 => "EventNodeCreated",
     2 => "EventNodeDeleted",
     3 => "EventNodeDataChanged",
     4 => "EventNodeChildrenChanged"
  }
  
  module Event
    None                = -1
    NodeCreated         =  1
    NodeDeleted         =  2
    NodeDataChanged     =  3
    NodeChildrenChanged =  4
  end
  
end