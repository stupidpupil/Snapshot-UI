require 'openssl'
require 'base32'
require 'cgi'

def requestToHash(req)
    if req.params.has_key?("path")
      return {:path => req.params["path"], :snapshot => req.params["snapshot"], :snapshot2 => req.params["snapshot2"]}
    else
      split = req.path.split("/")
      begin
        hash = degenerateLinkId(split[-2])
        hash2 = degenerateLinkId(split[-1])
        hash[:snapshot2] = hash2[:snapshot]
        return hash
      rescue
        begin
          return degenerateLinkId(split[-1])
        rescue
          return {}
        end
      end
    end
end

if File.exists?("key")
  KEY = File.open("key").read.to_s
else
  puts "Generating link encryption key..."
  o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten 
  rand  =  (0..256).map{ o[rand(o.length)]  }.join
  KEY = rand
  file = File.new("key", "w")
  file.puts(rand)
  file.close
end

module Blowfish
   def self.cipher(mode, key, data)
     cipher = OpenSSL::Cipher::Cipher.new('bf-cbc').send(mode)
     cipher.key = Digest::SHA256.digest(key)
     cipher.update(data) << cipher.final
   end

   def self.encrypt(key, data)
     cipher(:encrypt, key, data)
   end

   def self.decrypt(key, text)
     cipher(:decrypt, key, text)
   end
end

def generateLinkIdFor(path, snapshot)
  string = "#{rand}|#{path}|#{rand}|#{snapshot}|#{rand}"
  return CGI.escape(Base32.encode(Blowfish.encrypt(KEY, string)))
end

def degenerateLinkId(linkID)
  string = Blowfish.decrypt(KEY, Base32.decode(CGI.unescape(linkID)))
  split = string.split("|")
  path = split[1]
  snapshot = split[-2]
  
  hash = {:path => path, :snapshot => snapshot}
  return hash
end