class ZooKeeper
  ACL = com.yahoo.zookeeper.data.ACL
  class ACL
    OPEN_ACL_UNSAFE = Java::ArrayList.new(Java::Collections.singletonList(ACL.new(Permission::ALL, Id::ANYONE_ID_UNSAFE)))
    CREATOR_ALL_ACL = Java::ArrayList.new(Java::Collections.singletonList(ACL.new(Permission::ALL | Permission::ADMIN, Id::AUTH_IDS)))
    READ_ACL_UNSAFE = Java::ArrayList.new(Java::Collections.singletonList(ACL.new(Permission::READ, Id::ANYONE_ID_UNSAFE)))
    alias permissions getPerms
    alias id getId
  end
end