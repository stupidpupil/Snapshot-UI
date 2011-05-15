require 'plist'

class IWorkPreviewer < PreviewHandler
  
  def self.canPreviewPath(actualPath)
    return true if File.exists?(actualPath+"/QuickLook/Thumbnail.jpg")
    return true if `unzip -t "#{actualPath}"`.match("testing: QuickLook/Thumbnail.jpg   OK").nil?
    return false
  end
  
  def self.previewForPath(actualPath)
    return PNGPreviewer.previewForPath(actualPath+"/QuickLook/Thumbnail.jpg") if File.exists?(actualPath+"/QuickLook/Thumbnail.jpg")

    unless File.directory?(actualPath)
      data = `unzip -p "#{actualPath}" "QuickLook/Thumbnail.jpg"` unless `unzip -t "#{actualPath}"`.match("testing: QuickLook/Thumbnail.jpg   OK").nil?
      dataURI = "data:image/jpg;base64,#{Base64.encode64(data)}".delete("\n") unless data.nil? 
      return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil) unless dataURI.nil?
    end

  end
  
end
    

$handlers["application/x-iwork-pages-sffpages"] = IWorkPreviewer
$handlers["application/x-iwork-keynote-sffkey"] = IWorkPreviewer


class GrafflePreviewer < PreviewHandler
  
  def self.canPreviewPath(actualPath)
    return true if File.exists?(actualPath+"/QuickLook/Thumbnail.tiff")
    doc =  Plist::parse_xml(actualPath)
    return true unless doc['QuickLookThumbnail'].nil? 
    return false
  end 
  
  
  def self.previewForPath(actualPath)
  return JPEGPreviewer.previewForPath(actualPath+"/QuickLook/Thumbnail.tiff") if File.exists?(actualPath+"/QuickLook/Thumbnail.tiff")

  unless File.directory?(actualPath)
    doc =  Plist::parse_xml(actualPath)
    dataURI = "data:image/tiff;base64,#{Base64.encode64(doc['QuickLookThumbnail'].read)}".delete("\n") unless doc['QuickLookThumbnail'].nil? 
    return eruby = Erubis::Eruby.new("<img src=\"#{dataURI}\"/>").evaluate(nil) unless dataURI.nil?
  end
  
  return "<span class=\"previewError\"> Unable to generate preview.</span>" 
end
end