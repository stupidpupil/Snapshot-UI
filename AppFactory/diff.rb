module SPSnapshot
  class UIAppFactory
    def diffApp
      return proc do |env|
        req = Rack::Request.new(env)
        reqHash = requestToHash(req)
        path = reqHash[:path]

        snapshots = helper.snapshotsForPath(path)
        return [404, {"Content-Type" => "text/plain"}, ["No snapshots found for path."]] if snapshots.length == 0

        snapshot1 = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
        snapshot2 = snapshots.find {|x| x.snapId == reqHash[:snapshot2]}
        return [410, {"Content-Type" => "text/plain"}, ["Path does not exist in snapshot."]] if snapshot1.nil? or snapshot2.nil?

        return diffHandler(env, helper)
        
      end
    end
  end
end