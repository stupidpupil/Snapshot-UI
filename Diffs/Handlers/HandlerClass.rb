class DiffHandler
  
  def self.canDiff(relativePath, snapshot1, snapshot2, helper)
    return true
  end
  
  def self.diff(relativePath, snapshot1, snapshot2, helper)
    return ""
  end
  
  def self.respond(env, helper)
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)      
    
    path = reqHash[:path]
    
    snapshots = helper.snapshotsForPath(path)
    
    snapshot1 = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
    snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}

    
    eruby = Erubis::Eruby.new(File.read("Diffs/Diff.rxhtml"))
                
    context = {:diffContent => self.diff(path, snapshot1, snapshot2, helper) }
    
    return [200, {"Content-Type" => "application/xhtml+xml","Cache-Control" => "private, max-age=600"}, [eruby.evaluate(context)]]
    
  end
  
end