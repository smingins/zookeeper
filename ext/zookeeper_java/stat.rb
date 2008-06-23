class ZooKeeper
  Stat = com.yahoo.zookeeper.data.Stat
  class Stat
    alias created_zxid       getCzxid 
    alias last_modified_zxid getMzxid
    alias created_time       getCtime
    alias last_modified_time getMtime
    alias version            getVersion
    alias child_list_version getCversion
    alias acl_list_version   getAversion
    alias ephemeral_owner    getEphemeralOwner    
  end
end