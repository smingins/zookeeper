require 'monitor'

class ZooKeeper

  class SyncPrimitive

    @@zk =nil
    @@monitor = nil
    @@consume = nil

    attr_accessor :root

    def initialize(address)
      unless @@zk 
      	$LOG.info 'Connecting Zookeeper Client'
        @@zk = ZooKeeper.new(:host => address, :timeout => 10000, :watcher => self)
        @@monitor = Monitor.new
        @@consume = @@monitor.new_cond
      	$LOG.info 'Zookeeper Client Started'
      end
    rescue Exception => e
    	$LOG.error "Exception connecting Zookeeper to #{address} #{e.message}"
      @@zk = nil
    end

    def process(event)
      @@monitor.synchronize { @@consume.signal }
    end

  end

end