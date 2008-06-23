module JavaIO     
   include_package "java.io"
 end
 
class ZooKeeperTestServer
  
  DEFAULT_TICK_TIME = 3000

  def self.start(port)
    @server = ZooKeeperTestServer.new(port)
    @server.start
    wait_until { @server.is_running? }
    return @server
  end
  
  def self.stop
    @server.stop
    wait_until { !@server.is_running? }
  end
  
  def initialize(port, directory='zookeeper_test_server')
    @port = port
    @directory = "#{directory}_#{port}"
  end
  
  def start
    create_server_directory
    @zks = create_zookeeper_server
    @thread =  Java::NIOServerCnxn::Factory.new(@port)
    @thread.startup(@zks)
  end
  
  def stop
    @thread.shutdown()
    remove_server_directory
  end
  
  def is_running?
    @zks.is_running
  end
  
  private
  
  def create_server_directory
    FileUtils.remove_dir(@directory, true)
    FileUtils.mkdir(@directory)
  end
  
  def remove_server_directory
    FileUtils.remove_dir(@directory, true)
  end
  
  def create_zookeeper_server
    Java::ServerStats.registerAsConcrete()
    return Java::ZooKeeperServer.new(JavaIO::File.new(@directory), JavaIO::File.new(@directory), DEFAULT_TICK_TIME, Java::ZooKeeperServer::BasicDataTreeBuilder.new)
  end
  
end