require 'erubis'

$handlers = {} unless $handlers

def previewHandler(path, snapshot, helper)
  eruby = Erubis::Eruby.new(File.read("Previews/Preview.rxhtml"))
  
    actualPath = helper.absPathForRelPathAndSnapshot(path, snapshot)
  
    context = {:previewContent => $handlers[mimetypeForPath(actualPath)].previewForPath(actualPath)}
  
  return [200, {"Content-Type" => "application/xhtml+xml","Cache-Control" => "private, max-age=600"}, [eruby.evaluate(context)]]

end

def canPreview(actualPath)
  return true if $handlers.has_key?(mimetypeForPath(actualPath)) and $handlers[mimetypeForPath(actualPath)].canPreviewPath(actualPath)
  return false
end

require 'Previews/Handlers/HandlerClass.rb'
require 'Previews/Handlers/coderay.rb'
require 'Previews/Handlers/images.rb'
require 'Previews/Handlers/iwork.rb'