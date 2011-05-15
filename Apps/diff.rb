def diffAppWithHelper(helper)
  return proc do |env|
  req = Rack::Request.new(env)
  reqHash = requestToHash(req)
  path = reqHash[:path]
  
  snapshots = helper.snapshotsForPath(path)
  return [404, {"Content-Type" => "application/json"}, ["No snapshots found for path."]] if snapshots.length == 0
  
  snapshot1 = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
  snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}
  return [410, {"Content-Type" => "application/json"}, ["Path does not exist in snapshot."]] if snapshot1.nil? or snapshot2.nil?
  
  return diffHandler(path, snapshot1, snapshot2, helper)
  end
end