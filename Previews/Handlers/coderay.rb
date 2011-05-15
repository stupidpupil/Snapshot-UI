require 'coderay'

class CodeRayPreviewer < PreviewHandler
  def self.previewForPath(absolutePath)
    mimetype = mimetypeForPath(absolutePath)
    mm = {"application/x-ruby" => :ruby, "text/x-ruby" => :ruby, "application/javascript" => :javascript, "text/css" => :css, "text/x-c" => :c, "application/xhtml+xml" => :xhtml, "application/xml" => :xml}
    return CodeRay.scan(File.new(absolutePath).read.to_s, mm[mimetype]).div(:css => :class)
  end
end

$handlers["application/x-ruby"] = CodeRayPreviewer
$handlers["text/x-ruby"] = CodeRayPreviewer
$handlers["application/javascript"] = CodeRayPreviewer
$handlers["text/css"] = CodeRayPreviewer
$handlers["text/x-c"] = CodeRayPreviewer
$handlers["application/xhtml+xml"] = CodeRayPreviewer
$handlers["application/xml"] = CodeRayPreviewer
$handlers["text/plain"] = CodeRayPreviewer