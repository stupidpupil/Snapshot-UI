
module SPSnapshot

  class SnapshotHelper
    
    #Happens to implement a demo class 
    # baseDir/snap1
    # baseDir/snap2
    # I think this might actually work for BtrFS snapshots, if you point it at a volume mount point!

    def initialize(baseDir)
      @baseDir = baseDir
    end
    
    def startingPath
      return File.split(@baseDir)[1]
    end

    def snapshots #Should return an Array of Snapshots ordered by date from latest to oldest
      return Dir.new(@baseDir).find_all{|x| (x != "." and x != ".." and File.directory?(@baseDir+"/"+x))}.map{|x| Snapshot.new(x, x.capitalize, File.mtime(@baseDir+"/"+x))}
    end

    def absPathForRelPathAndSnapshot(relativePath, snapshot)      
      absolutePath = @baseDir + "/" + snapshot.snapId + relativePath[File.split(@baseDir)[1].length..-1]
      return absolutePath 
    end


    # Common, if not ubiquitous methods

    def snapshotsForPath(relativePath)
      return self.snapshots.find_all{|x| File.exists?(absPathForRelPathAndSnapshot(relativePath, x))}
    end

    def versionsForPath(relativePath)
      snapshots = snapshotsForPath(relativePath)

      retArray = []
      thisVersion = []

      latestSnapshot = snapshots[0]
      lastVersionPath = absPathForRelPathAndSnapshot(relativePath, latestSnapshot)
      thisVersion << latestSnapshot
      
      #
      # Some exciting checks!
      #

      mtimeCheck = proc do |path1, path2|
        return File.mtime(path1) != File.mtime(path2)
      end
      
      cksumCheck = proc do |path1, path2|
        ck1 = `cksum "#{path1}"`.split(" ")[0..1]
        ck2 = `cksum "#{path2}"`.split(" ")[0..1]
        return ck1 != ck2
      end
      
      inodeCheck = proc do |path1, path2|
        return `ls -i "#{path1}"`.split(" ")[0] != `ls -i "#{path2}"`.split(" ")[0]
      end
      
      multiCheck = proc do |path1, path2|
        return ((inodeCheck.call(path1, path2) or mtimeCheck.call(path1, path2)) and cksumCheck.call(path1, path2))
      end
      
      #

      snapshots[1..-1].each do |snap|
        thisVersionPath = absPathForRelPathAndSnapshot(relativePath, snap)

        if pathsDiffer(thisVersionPath, lastVersionPath, multiCheck)
          retArray << thisVersion
          thisVersion = []
        end
        
        lastVersionPath = thisVersionPath
    
        thisVersion << snap
      end

      retArray << thisVersion
      return retArray
    end
    
    def pathsDiffer(path1, path2, checkProc, recursive=true)
      return true if (File.directory?(path1) != File.directory?(path2))

      if (not File.directory?(path1) and not File.directory?(path2))
        return checkProc.call(path1, path2)
      end

      #So. They must both be directories.
      dir1 = Dir.new(path1)
      dir2 = Dir.new(path2)

      entries1 = dir1.entries.delete_if {|x| not File.fnmatch("*", x)}
      entries2 = dir2.entries.delete_if {|x| not File.fnmatch("*", x)}

      return true if entries1 != entries2

      #
      # Do files first because getting entries is relatively expensive
      # (Compared to mtime; depends on what you're actually using to check files.)

      entries1.delete_if {|x| File.directory?(x)}.each do |entry|
        return true if pathsDiffer("#{path1}/#{entry}", "#{path2}/#{entry}", checkProc, recursive)
      end

      return false unless recursive

      entries1.delete_if {|x| not File.directory?(x)}.each do |entry|
        return true if pathsDiffer("#{path1}/#{entry}", "#{path2}/#{entry}", checkProc, recursive)
      end

      return false
    end

  end

end



