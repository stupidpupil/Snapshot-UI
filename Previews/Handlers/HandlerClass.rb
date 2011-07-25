class PreviewHandler
  
  def self.canPreviewPath(absolutePath)
    return true
  end
  
  def self.previewForPath(absolutePath)
    return ""
  end
  
  def self.respond(env, helper)
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)      
    
    path = reqHash[:path]

    snapshots = helper.snapshotsForPath(path)

    snapshot = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
    
    eruby = Erubis::Eruby.new(File.read("Previews/Preview.rxhtml"))

    actualPath = helper.absPathForRelPathAndSnapshot(path, snapshot)
    
    mimetype = MIME::Types.type_for_path(actualPath)[0].to_s
    
    context = {:previewContent => $handlers[mimetype].previewForPath(actualPath)}
    
    return [200, {"Content-Type" => "application/xhtml+xml","Cache-Control" => "private, max-age=600"}, [eruby.evaluate(context)]]
    
  end
  
end

class ImagePreviewHandler < PreviewHandler
  
  def self.respond(env, helper)
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)      
    
    path = reqHash[:path]

    snapshots = helper.snapshotsForPath(path)

    snapshot = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
    
    if req.params.has_key?("image")
            
      actualPath = helper.absPathForRelPathAndSnapshot(path, snapshot)
      
      return self.imageForPath(actualPath)
      
    else
    
      eruby = Erubis::Eruby.new(File.read("Previews/Preview.rxhtml"))
          
      context = {:previewContent => "<img src=\"/preview/#{generateLinkIdFor(path, snapshot.snapId)}/?image\"/>"}
    
      return [200, {"Content-Type" => "application/xhtml+xml","Cache-Control" => "private, max-age=600"}, [eruby.evaluate(context)]]
    
    end
    
  end
  
  def self.imageForPath(actualPath)
    return [200, {"Content-Type" => "image/png","Cache-Control" => "private, max-age=600"}, [""]]
  end
  
  
end