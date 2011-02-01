require 'digest/sha1'

class Backuper
  def keys_bak(params)
    pwd = File.expand_path(params['to'])
    p=KeysBac.new params['name']
    begin 
      p.backup_keys pwd
    rescue KeysBacException => e
      return keys_bak_msg + "#{e.message}"
    rescue IOError => e
      return keys_bak_msg + "IOError: #{e.errno} #{e.message}"
    rescue SystemCallError => e
      return keys_bak_msg + "SystemCallError: #{e.errno} #{e.message}"
    end
  end
end

class KeysBac
  def initialize(name,rewrite=false)
    @name = name
    @secret = `gpg --export-secret-keys '#{name}'`
    return "Can't get secret key for #{name}" if not $?.success?
    @pub = `gpg --export '#{name}'`
    return "Can't get public key for #{name}" if not $?.success?
    @pub_file = '/' + name + ".pub"
    @sec_file = '/' + name + ".secret"
  end

  def is_same_hash?(dest, name)
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
    is_same_hash?(sec_file, @secret)
  end
  
  def same_keys?(destination)
    if is_seckey_same?(destination) and is_pubkeys_same?(destination)
      true
      else false
    end
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

  # Check that both keys or no one exist at destination
  def is_dest_consistent?(destination)
    if is_pubfile_exist?(destination) and not is_secfile_exist?(destination) or
        not is_pubfile_exist?(destination) and is_secfile_exist?(destination)
      false
    else 
      true
    end
  end
  
  # Actually writing keys here
  def write_keys(destination)
    begin
      File.open(destination + @pub_file, 'w') do |f|
        f.write @pub
      end
      File.open(destination + @sec_file, 'w') do |f|
        f.write @secret
      end
    # rescue IOError => e
    #   return "IOError: #{e.errno} #{e.message}"
    end
  end

  # Check that destination is a directory and create if it's not exist
  def check_dest_existance(destination)
    if File.file?(destination)
      raise KeysBacException, "Error: destination is regular file, should be directory!"
    elsif not Dir.exist?(destination)
      begin
        Dir.mkdir destination
      # rescue SystemCallError => e
      #    "SystemCallError: #{e.errno} #{e.message}"
      end
    end
  end
  
  def backup_keys(destination)
    check_dest_existance destination
    if is_dest_consistent? destination 
      if not key_files_exists? destination
        write_keys destination
      end
      if not same_keys? destination
        raise KeysBacException, "Error: Something bad happened during keys files check, keys are wrong!"
      end
    else 
      raise KeysBacException, "Error: Keys dest is not consistent, fix it first!"
    end
  end
  
end

class KeysBacException < Exception
end
