class ZooKeeper
  DEFAULTS = {
    :timeout => 10000
  }
end

require 'zookeeper_java/java'
require 'zookeeper_java/keeper_exception'
require 'zookeeper_java/event'
require 'zookeeper_java/state'
require 'zookeeper_java/create_flag'
require 'zookeeper_java/permission'
require 'zookeeper_java/watcher_event'
require 'zookeeper_java/stat'
require 'zookeeper_java/id'
require 'zookeeper_java/acl'
require 'zookeeper_java/async_callback'
require 'zookeeper_java/default_watcher'
require 'zookeeper_java/zookeeper'
require 'zookeeper/sync_primitive'
require 'zookeeper/queue'
require 'zookeeper/logging'
