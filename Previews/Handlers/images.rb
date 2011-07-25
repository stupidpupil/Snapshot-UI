class JPEGPreviewer < ImagePreviewHandler
  
  def self.imageForPath(actualPath)
    
    maxResolution = "768x768"
    maxSizeBytes = 290*1024
    quality = 90


    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"

    `cp "#{actualPath}" "#{intermediatePath}"`

    `convert "#{intermediatePath}[0]" -thumbnail "#{maxResolution}>" -strip "#{intermediatePath}.tiff"`

    outputSizeBytes = maxSizeBytes + 1
    while outputSizeBytes > maxSizeBytes and quality-7 >= 5
    	quality -= 7
    	jpegOut = `convert "#{intermediatePath}.tiff" -quality #{quality} jpg:-`
    	outputSizeBytes = jpegOut.size
    end

    File.delete(intermediatePath)
    File.delete("#{intermediatePath}.tiff")
    
    return [200, {"Content-Type" => "image/jpeg","Cache-Control" => "private, max-age=600"}, [jpegOut]]
    
  end
  
end

class PNGPreviewer < ImagePreviewHandler
  def self.imageForPath(actualPath)
    maxResolution = "768x768"
    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"
    `cp "#{actualPath}" "#{intermediatePath}"`
    pngOut = `convert "#{intermediatePath}" -thumbnail "#{maxResolution}>" -strip png:-`
    File.delete(intermediatePath)
    return [200, {"Content-Type" => "image/png","Cache-Control" => "private, max-age=600"}, [pngOut]]
  end
  
end

$handlers["image/png"] = PNGPreviewer
$handlers["image/jpeg"] = JPEGPreviewer
$handlers["image/tiff"] = JPEGPreviewer
$handlers["image/vnd.adobe.photoshop"] = JPEGPreviewer

class PDFPreviewer < ImagePreviewHandler
  def self.imageForPath(actualPath)
    maxResolution = "1024x1024"
    intermediatePath = "#{Dir.tmpdir}/qlTmpDir.#{Process.pid}.#{File.basename(actualPath)}"
    `cp "#{actualPath}" "#{intermediatePath}"`
    pngOut = `convert "#{intermediatePath}[0]" -thumbnail "#{maxResolution}>" -strip png:-`
    File.delete(intermediatePath)
    return [200, {"Content-Type" => "image/png","Cache-Control" => "private, max-age=600"}, [pngOut]]
  end
end

$handlers["application/pdf"] = PDFPreviewer
$handlers["application/postscript"] = PDFPreviewer
