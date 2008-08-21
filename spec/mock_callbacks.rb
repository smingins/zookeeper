class MockStringCallback
  
  attr_accessor :return_code, :path, :context, :name, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context, name)
    @return_code, @path, @context, @name = return_code, path, context, name
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end

class MockVoidCallback
  
  attr_accessor :return_code, :path, :context, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context)
    @return_code, @path, @context = return_code, path, context
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end

class MockStatCallback
  
  attr_accessor :return_code, :path, :context, :stat, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context, stat)
    @return_code, @path, @context, @stat = return_code, path, context, stat
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end

class MockChildrenCallback
  
  attr_accessor :return_code, :path, :context, :children, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context, children)
    @return_code, @path, @context, @children = return_code, path, context, children
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end

class MockDataCallback
  
  attr_accessor :return_code, :path, :context, :data, :stat, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context, data, stat)
    @return_code, @path, @context, @data, @stat = return_code, path, context, data, stat
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end

class MockAclCallback
  
  attr_accessor :return_code, :path, :context, :acl, :stat, :completed
  
  def initialize
    @completed = false
  end

  def process_result(return_code, path, context, acl, stat)
    @return_code, @path, @context, @acl, @stat = return_code, path, context, acl, stat
    @completed = true
  end
  
  def process_result_completed?
    return @completed
  end
  
end
