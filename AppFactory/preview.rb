module SPSnapshot
  class UIAppFactory
    def previewApp
      return proc do |env|
        req = Rack::Request.new(env)
        reqHash = requestToHash(req)      

        path = reqHash[:path]

        snapshots = helper.snapshotsForPath(path)
        return [404, {"Content-Type" => "text/plain"}, ["No snapshots found for path."]] if snapshots.length == 0

        snapshot = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
        return [410, {"Content-Type" => "text/plain"}, ["Path does not exist in snapshot."]] if snapshot.nil?

        return previewHandler(path, snapshot, helper)
      end

    end
  end
end