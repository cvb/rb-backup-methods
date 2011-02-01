class Backuper
  def rdiff_backup(params)
    result = `rdiff-backup #{params['from']} #{params['to']}`
    return result if not $?.success?
  end
end
