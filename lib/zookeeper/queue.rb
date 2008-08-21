class ZooKeeper

  class Queue < SyncPrimitive

    def initialize(address, name)
      super(address)
      until @@zk.connected? do; end
      @root = name
      if @@zk && @@zk.exists(@root).nil?
        @@zk.create(:path => @root, :data => "") 
      end
    rescue Exception => e
     	$LOG.error "Exception instantiating queue #{e.message}"
    end

    def produce(data)
      @@zk.create(:path => "#{@root}/element", :data => data, :sequence => true) and return true
    end

    def consume
      @@monitor.synchronize do
        loop do
          list = @@zk.children(:path => @root, :watch => true)

          if list.empty?
           	$LOG.info 'Queue empty, going to wait'
            @@consume.wait
          else
            minimum_node = list.inject {|e1, e2| e2.delete("element").to_i < e1.delete("element").to_i ? e2 : e1 }
            data, stat = @@zk.get("#{@root}/#{minimum_node}")
            @@zk.delete(:path => "#{@root}/#{minimum_node}", :version => 0)
            return data
          end
        end
      end
    end
    
    def empty?
      @@zk.children(:path => @root).empty?
    end
    
    def stop
      @@zk.close
      @@zk = nil
    end
    
    def stopped?
      @@zk.nil?
    end
    
    def active?
      @@zk.connected?
    end

  end

end