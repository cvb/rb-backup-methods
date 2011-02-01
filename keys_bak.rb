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
  def initialize(name,rewrite=false,)
    @name = name
    @secret = `gpg --export-secret-keys '#{name}'`
    return "Can't get secret key for #{name}" if not $?.success?
    @pub = `gpg --export '#{name}'`
    return "Can't get public key for #{name}" if not $?.success?
    @pub_file = name + ".pub"
    @sec_file = name + ".secret"
  end

  def is_same_hash?(dest, name)
    puts "File dest: #{dest}"
    puts "Sha orig: #{Digest::SHA1.hexdigest name}"
    puts "Sha backed: #{Digest::SHA1.hexdigest (File.open dest).read}"
    if File.file?(dest) and ((Digest::SHA1.hexdigest name) == (Digest::SHA1.hexdigest (File.open dest).read))
      true
    else false
    end
  end
  
  # Check hashes of existence keys and current
  def is_pubkeys_same?(destination)
    pub_file = destination + @pub_file
    is_same_hash?(pub_file, @pub)
  end
  def is_seckey_same?(destination)
    sec_file = destination + @sec_file
    is_same_hash?(pub_file, @secret)
  end
  
  # Check for existence of key files in destination
  def is_pubfile_exist?(destination)
    if File.file?(destination + @pub_file)
      true
      else false
    end
  end
  def is_secfile_exist?(destination)
    if File.file?(destination + @sec_file)
      true
      else false
    end
  end
  
  def key_files_exists?(destination)
    if is_pubfile_exist?(destination) and is_secfile_exist?(destination)
      true
      else false
    end
  end

  def is_dest_consistent?(destination)
    if is_pubfile_exist?(destination) and not is_secfile_exist?(destination) or
        not is_pubfile_exist?(destination) and is_secfile_exist?(destination)
      true
    else false
    end
  end
  
  def backup_keys(destination)
    if key_files_exists?(destination)
      
    end
  end

end

p=KeysBac.new('Peter <peter@standalone.su>')
puts p.is_seckey_same?("/mnt/store/backup/")
