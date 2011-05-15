MIMETypesLines = File.new("Metadata/mime.types").read.lines.find_all{|x| !x.match(/^#.+$/)}

def mimetypeForPath(path)
   
    MIMETypesLines.each do |line|
      split = line.split
      if split.count > 1

        split[1..-1].each do |ext|
          return split[0] if ext == File.extname(File.basename(path.downcase))[1..-1]
        end

      end
    end
    
  
  return "application/x-directory" if File.directory?(path)
  
  return `file --mime-type -Lb "#{path}"`.strip
end

def kindForPath(path)
  return `file -b "#{path}"`
end

def isFolder?(path)
  return false if not File.directory?(path)
  return false if mimetypeForPath(path) != "application/x-directory"
  return true
end