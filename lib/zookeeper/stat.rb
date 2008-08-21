class ZooKeeper
  class Stat
    attr_reader :created_zxid, :last_modified_zxid, :created_time, :last_modified_time, :version, :child_list_version,
                :acl_list_version, :ephemeral_owner     

    def initialize(attributes)
      @created_zxid, @last_modified_zxid, @created_time, @last_modified_time, @version, 
      @child_list_version, @acl_list_version, @ephemeral_owner = attributes
    end
  end
end