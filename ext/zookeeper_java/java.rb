class ZooKeeper

  include Java
  
  module Java
    require 'zookeeper_java/zookeeper-dev.jar'
    require 'zookeeper_java/log4j-1.2.15.jar'
    include_package "com.yahoo.zookeeper"
    include_package "com.yahoo.zookeeper.data"
    include_package "java.util"
  end
    
end


