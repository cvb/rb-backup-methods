require 'digest/sha1'

class Backuper
  def keys_bak(to, name)
    pwd = File.expand_path(dir)
    return "Destination exist and not dir: #{to}" if File.file? pwd
    secret = `gpg --export-secret-keys '#{name}'`
    pub = `gpg --export-keys '#{name}'`
    begin
      Dir.mkdir pwd if nor Dir.exist? pwd
      
      rescue SystemCallError => e
      return "SystemCallError: #{e.errno} #{e.message}"
    end
  end
end

class KeysBac
  def initialize(name)
    @name = name
    @secret = `gpg --export-secret-keys '#{name}'`
    return "Can't get secret key for #{name}" if not $?.success?
    @pub = `gpg --export '#{name}'`
    return "Can't get public key for #{name}" if not $?.success?
  end

  def is_same_hash?(dest, name)
    puts "File dest: #{dest}"
    puts "Sha orig: #{Digest::SHA1.hexdigest name}"
    puts "Sha backed: #{Digest::SHA1.hexdigest (File.open dest).read}"
    if File.file?(dest) and ((Digest::SHA1.hexdigest name) == (Digest::SHA1.hexdigest (File.open dest).read))
      return true
    else return false
    end
  end
  
  def is_pubkeys_same?(destination)
    pub_file = destination + @name + ".pub"
    is_same_hash?(pub_file, @pub)
  end
  def is_seckey_same?(destination)
    pub_file = destination + @name + ".secret"
    is_same_hash?(pub_file, @secret)
  end
end

p=KeysBac.new('Peter <peter@standalone.su>')
puts p.is_seckey_same?("/mnt/store/backup/")
