class ZooKeeper
  class Id
    attr_reader :scheme, :identification 

    def initialize(scheme, id)
      @scheme, @identification = scheme, id
    end

    def ==(obj)
      self.scheme == obj.scheme &&
      self.identification == obj.identification
    end
    

    ANYONE_ID_UNSAFE = Id.new("world", "anyone")
    AUTH_IDS         = Id.new("auth", "")
  end
end