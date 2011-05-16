module SPSnapshot
  class UIAppFactory


def infoHashFor(path, snapshot)
  retHash = {}
  retHash[:link] = generateLinkIdFor(path, snapshot.snapId)
  retHash[:filename] = File.basename(path)
  retHash[:path] = path
  retHash[:snapId] = snapshot.snapId
  
  absolutePath = helper.absPathForRelPathAndSnapshot(path, snapshot)
  
  entries = []
  if File.directory?(absolutePath)
    dir = Dir.new(absolutePath)

    dir.entries.delete_if {|x| x[0..0] == "." }.each do |entry|
      entryPath = absolutePath+"/"+entry
      hash = {:filename => entry}

      unless File.directory?(entryPath)
        hash[:size] = File.size(entryPath)
      end
      
      hash[:folder] = isFolder?(entryPath)
      
      hash[:mtime] = File.mtime(entryPath).to_i
      entries << hash
    end
  end
  
  retHash[:entries] = entries 
  retHash[:kind] = kindForPath(absolutePath)
  retHash[:mimetype] = mimetypeForPath(absolutePath)
  retHash[:preview] = canPreview(absolutePath)  
  retHash[:ctime] = File.ctime(absolutePath).to_i
  retHash[:mtime] = File.mtime(absolutePath).to_i
  retHash[:size] = (mimetypeForPath(absolutePath) == "application/x-directory" ? nil : File.size(absolutePath))
  
  return retHash
  
end

def infoApp
  return proc do |env|  
    
    
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)
    path = reqHash[:path]
    
    snapshots = helper.snapshotsForPath(path)
    return [404, {"Content-Type" => "text/plain"}, ["No snapshots found for path."]] if snapshots.length == 0
    
    snapshot = snapshots.find {|x| x.snapId == reqHash[:snapshot]}

    if snapshot.nil?
      retHash = {:info => nil}
    else
      retHash = {:info => infoHashFor(path, snapshot)}
    end
    
    if(reqHash[:snapshot2])
      snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}     
      if snapshot2.nil?
        retHash[:info2] = nil
      else
        retHash[:info2] = infoHashFor(path, snapshot2)
      end 
    end
    
    unless snapshot.nil? or snapshot2.nil?
      retHash[:diffable] = canDiff(path, snapshot, snapshot2, helper) 
    end

    return [200, {"Content-Type" => "application/json", "Expires" => (Time.now + 10.years).rfc2822,"Cache-Control" => "private, max-age=5000000"}, [retHash.to_json ]]
    
  end

end

end
end