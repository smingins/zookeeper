class ZooKeeper
  class DefaultWatcher
    import com.yahoo.zookeeper.Watcher
    def process(event)
      puts "#{event.class} received --- with path = #{event.get_path} --- state = #{ZooKeeper::CONNECTION_STATES[event.get_state]} --- type = #{ZooKeeper::EVENT_TYPES[event.get_type]}"
    end
  end
end