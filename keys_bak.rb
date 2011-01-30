class Backuper
  def keys_bak(to, name)
    secret = `gpg --export-secret-keys '#{name}'`
    pub = `gpg --export-keys '#{name}'`
    
  end
end
