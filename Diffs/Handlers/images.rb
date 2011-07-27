class ImageDiffHandler < DiffHandler
  
  def self.respond(env, helper)
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)      
    
    path = reqHash[:path]

    snapshots = helper.snapshotsForPath(path)

    snapshot1 = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
    snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}
    
    if req.params.has_key?("image")
      
      return self.imageDiff(path, snapshot1, snapshot2, helper)
      
    else
    
      eruby = Erubis::Eruby.new(File.read("Previews/Preview.rxhtml"))
    
      context = {:previewContent => "<img src=\"/diff/#{generateLinkIdFor(path, snapshot1.snapId)}/#{generateLinkIdFor(path, snapshot2.snapId)}?image\"/>"}
    
      return [200, {"Content-Type" => "application/xhtml+xml","Cache-Control" => "private, max-age=600"}, [eruby.evaluate(context)]]
    
    end
    
  end
  
  
  def self.imageDiff(relativePath, snapshot1, snapshot2, helper)
    
    maxResolution = "768x768"

    abs1 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot1)
    abs2 = helper.absPathForRelPathAndSnapshot(relativePath, snapshot2)
    in1 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.1.#{File.basename(abs1)}"
    in2 = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.2.#{File.basename(abs1)}"

    `cp "#{abs1}" "#{in1}"`
    `cp "#{abs2}" "#{in2}"`


    pngOut = `convert -fuzz 5% -compose difference -composite "#{in1}[0]" "#{in2}[0]" -thumbnail "#{maxResolution}>" -strip png:-`
    
    return [200, {"Content-Type" => "image/png","Cache-Control" => "private, max-age=600"}, [pngOut]]
    
  end
  
end


$diffHandlers["image/png"] = ImageDiffHandler
$diffHandlers["image/jpeg"] = ImageDiffHandler
$diffHandlers["image/vnd.adobe.photoshop"] = ImageDiffHandler
$diffHandlers["application/postscript"] = ImageDiffHandler

