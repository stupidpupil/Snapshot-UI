require 'erubis'

$handlers = {} unless $handlers

def previewHandler(env, helper)
  req = Rack::Request.new(env)
  reqHash = requestToHash(req)      
  
  path = reqHash[:path]

  snapshots = helper.snapshotsForPath(path)

  snapshot = snapshots.find {|x| x.snapId == reqHash[:snapshot]}
  
  actualPath = helper.absPathForRelPathAndSnapshot(path, snapshot)
  
  mimetype = MIME::Types.type_for_path(actualPath)[0].to_s
  
  return $handlers[mimetype].respond(env, helper)
  
end

def canPreview(actualPath)
  mimetype = MIME::Types.type_for_path(actualPath)[0].to_s
  
  return true if $handlers.has_key?(mimetype) and $handlers[mimetype].canPreviewPath(actualPath)
  return false
end

require 'Previews/Handlers/HandlerClass.rb'
require 'Previews/Handlers/coderay.rb'
require 'Previews/Handlers/images.rb'
require 'Previews/Handlers/iwork.rb'
require 'Previews/Handlers/Archives.rb'