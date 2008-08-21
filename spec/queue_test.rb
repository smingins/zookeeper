$LOAD_PATH << "#{File.dirname(__FILE__)}/../ext" << "#{File.dirname(__FILE__)}/../lib"
# Ruby implementation of Queue and test from http://zookeeper.wiki.sourceforge.net/ZooKeeperTutorial
# You will need at least one ZooKeeper server running and listening for client on 2181
require 'zookeeper'

queue = ZooKeeper::Queue.new("localhost:2181,localhost:4000", "/app1")

max  = ARGV[0].to_i
type = ARGV[1]

begin
  if type == 'p'
    puts "Producer"
    max.times do |i|
      queue.produce(i.to_s)
    end
  end

  if type == 'c'
    puts "Consumer"
    max.times do |i|
      item = queue.consume();
      puts "Item: #{item}"
    end
  end
rescue Exception => e
  put "opps #{e}"
end