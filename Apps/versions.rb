def versionsAppWithHelper(helper)  
  return proc do |env|
    
    req = Rack::Request.new(env)
    reqHash = requestToHash(req)

    path = reqHash[:path]
      

    snapshots = helper.snapshotsForPath(path)
    return [404, {"Content-Type" => "application/json"}, ["No snapshots found for path."]] if snapshots.length == 0
    
    return [200, {"Content-Type" => "application/json", "Cache-Control" => "private, max-age=120"}, [{:versions => helper.versionsForPath(path)}.to_json]] if req.params["versions"] == "true"
    return [200, {"Content-Type" => "application/json", "Cache-Control" => "private, max-age=120"}, [{:snapshots => snapshots}.to_json]] 

  end
end