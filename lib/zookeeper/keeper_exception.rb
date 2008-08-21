class KeeperException < Exception

  OK                      = 0
  # System and server-side errors
  SYSTEMERROR             = -1
  RUNTIMEINCONSISTENCY    = SYSTEMERROR - 1
  DATAINCONSISTENCY       = SYSTEMERROR - 2
  CONNECTIONLOSS          = SYSTEMERROR - 3
  MARSHALLINGERROR        = SYSTEMERROR - 4
  UNIMPLEMENTED           = SYSTEMERROR - 5
  OPERATIONTIMEOUT        = SYSTEMERROR - 6
  BADARGUMENTS            = SYSTEMERROR - 7
  # API errors  
  APIERROR                = -100; 
  NONODE                  = APIERROR - 1 # Node does not exist
  NOAUTH                  = APIERROR - 2 # Current operation not permitted
  BADVERSION              = APIERROR - 3 # Version conflict
  NOCHILDRENFOREPHEMERALS = APIERROR - 8
  NODEEXISTS              = APIERROR - 10
  NOTEMPTY                = APIERROR - 11
  SESSIONEXPIRED          = APIERROR - 12
  INVALIDCALLBACK         = APIERROR - 13
  INVALIDACL              = APIERROR - 14
  AUTHFAILED              = APIERROR - 15 # client authentication failed
  
  class SystemError             < KeeperException; end
  class RunTimeInconsistency    < KeeperException; end
  class DataInconsistency       < KeeperException; end
  class ConnectionLoss          < KeeperException; end
  class MarshallingError        < KeeperException; end
  class Unimplemented           < KeeperException; end
  class OperationTimeOut        < KeeperException; end
  class BadArguments            < KeeperException; end
  class ApiError                < KeeperException; end
  class NoNode                  < KeeperException; end
  class NoAuth                  < KeeperException; end
  class BadVersion              < KeeperException; end
  class NoChildrenForEphemerals < KeeperException; end
  class NodeExists              < KeeperException; end
  class NotEmpty                < KeeperException; end
  class SessionExpired          < KeeperException; end
  class InvalidCallback         < KeeperException; end
  class InvalidACL              < KeeperException; end
  class AuthFailed              < KeeperException; end
  
  def self.by_code(code)
    case code
    when OK: Ok
    when SYSTEMERROR: SystemError
    when RUNTIMEINCONSISTENCY: RunTimeInconsistency
    when DATAINCONSISTENCY: DataInconsistency
    when CONNECTIONLOSS: ConnectionLoss
    when MARSHALLINGERROR: MarshallingError
    when UNIMPLEMENTED: Unimplemented
    when OPERATIONTIMEOUT: OperationTimeOut
    when BADARGUMENTS: BadArguments
    when APIERROR: ApiError
    when NONODE: NoNode
    when NOAUTH: NoAuth
    when BADVERSION: BadVersion
    when NOCHILDRENFOREPHEMERALS: NoChildrenForEphemerals 
    when NODEEXISTS: NodeExists              
    when NOTEMPTY: NotEmpty                
    when SESSIONEXPIRED: SessionExpired          
    when INVALIDCALLBACK: InvalidCallback         
    when INVALIDACL: InvalidACL
    when AUTHFAILED: AuthFailed
    else Exception.new("no exception defined for code #{code}")
    end
  end
end
