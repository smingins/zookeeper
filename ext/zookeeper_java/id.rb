class ZooKeeper
  Id = com.yahoo.zookeeper.data.Id
  class Id
    ANYONE_ID_UNSAFE = Id.new("world", "anyone")
    AUTH_IDS = Id.new("auth", "")
    alias id getId
  end
end