def downloadAppWithHelper(helper)  
  return proc do |env|
    req = Rack::Request.new(env)
    hash = requestToHash(req)
    
    path = hash[:path]
    snapshot = hash[:snapshot]

    snapshots = helper.snapshotsForPath(path)
    return [404, {"Content-Type" => "application/json"}, ["No snapshots found for path."]] if snapshots.length == 0
    
    snapshot = snapshots.find {|x| x.snapId == hash[:snapshot]}
    return [410, {"Content-Type" => "application/json"}, ["Path does not exist in snapshot."]] if snapshot.nil?

    absolutePath = helper.absPathForRelPathAndSnapshot(path, snapshot)
    
    if File.directory?(absolutePath)
      output = `tar -C "#{absolutePath}/.." -c --use-compress-prog=pbzip2 "#{File.basename(absolutePath)}"`
      name = "#{File.basename(absolutePath)}.tar.bz2"
      return [200, {"Content-Type" => "application/x-bzip2; name=\"#{name}\"", "Content-Disposition" => "attachment; filename=\"#{name}\"", "Content-Length" => "#{output.size}"}, [output]]
    end

    name = "#{File.basename(absolutePath)}"
    return [200, {"Content-Type" => "application/octet-stream; name=\"#{name}\"", "Content-Disposition" => "attachment; filename=\"#{name}\""}, [File.open(absolutePath).read]]    
  end
end