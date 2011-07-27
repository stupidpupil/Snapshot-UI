require 'plist'

class IWorkPreviewer < ImagePreviewHandler
  
  def self.canPreviewPath(actualPath)
    return true if File.exists?(actualPath+"/QuickLook/Thumbnail.jpg")
    return true unless File.directory?(actualPath) or `unzip -t "#{actualPath}"`.match("testing: QuickLook/Thumbnail.jpg   OK").nil?
    return false
  end
  
  def self.imageForPath(actualPath)
    return [200, {"Content-Type" => "image/jpeg","Cache-Control" => "private, max-age=600"}, [File.open(actualPath+"/QuickLook/Thumbnail.jpg").read]] if File.exists?(actualPath+"/QuickLook/Thumbnail.jpg")
    
    unless File.directory?(actualPath)
      data = `unzip -p "#{actualPath}" "QuickLook/Thumbnail.jpg"` unless `unzip -t "#{actualPath}"`.match("testing: QuickLook/Thumbnail.jpg   OK").nil?
      return [200, {"Content-Type" => "image/jpeg","Cache-Control" => "private, max-age=600"}, [data]] 
    end
 

  end
  
end
    

$handlers["application/x-iwork-pages-sffpages"] = IWorkPreviewer
$handlers["application/x-iwork-keynote-sffkey"] = IWorkPreviewer

MIME::Type.new("application/x-iwork-pages-sffpages") {|t| t.extensions = "pages"; MIME::Types.add(t)}
MIME::Type.new("application/x-iwork-keynote-sffkey") {|t| t.extensions = "key"; MIME::Types.add(t)}


class GrafflePreviewer < ImagePreviewHandler
  
  def self.canPreviewPath(actualPath)
    return true if File.exists?(actualPath+"/QuickLook/Thumbnail.tiff")
    return true unless File.directory?(actualPath) or Plist::parse_xml(actualPath)['QuickLookThumbnail'].nil? 
    return false
  end 
  
  
  def self.imageForPath(actualPath)
    return JPEGPreviewer.imageForPath(actualPath+"/QuickLook/Thumbnail.tiff") if File.exists?(actualPath+"/QuickLook/Thumbnail.tiff")
  
    unless File.directory?(actualPath)
      doc =  Plist::parse_xml(actualPath)
      intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}.tiff"
      int = File.new(intermediatePath,"w")
      int.puts(doc['QuickLookThumbnail'].read)
      int.close
      jpeg = JPEGPreviewer.imageForPath(intermediatePath)
      File.delete(intermediatePath)
      return jpeg
    end
  
  end
end

$handlers["application/x-graffle"] = GrafflePreviewer
MIME::Type.new("application/x-graffle") {|t| t.extensions = "graffle"; MIME::Types.add(t)}
