class ZooKeeper

  module AsyncCallback
    # you'd think this would work!!!   how do i refer to nested interface??
    # JavaUtilities.extend_proxy("com.yahoo.zookeeper.AsyncCallback.StringCallback") do
    #   alias process_result processResult
    # end
  
    module StringCallback
      def processResult(return_code, path, context, name)
        process_result(return_code, path, context, name)
      end
    end
  
    module VoidCallback
      def processResult(return_code, path, context)
        process_result(return_code, path, context)
      end
    end
  
    module StatCallback
      def processResult(return_code, path, context, stat)
        process_result(return_code, path, context, stat)
      end
    end
  
    module ChildrenCallback
      def processResult(return_code, path, context, children)
        process_result(return_code, path, context, children.to_a)
      end
    end
  
    module DataCallback
      def processResult(return_code, path, context, data, stat)
        process_result(return_code, path, context, String.from_java_bytes(data), stat)
      end
    end

    module AclCallback
      def processResult(return_code, path, context, acl, stat)
        process_result(return_code, path, context, acl.to_a, stat)
      end
    end

  end

end