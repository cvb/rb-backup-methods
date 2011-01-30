class Backuper
  def rdiff_backup(from, to)
    result = `rdiff-backup #{from} #{to}`
    return result if not $?.success?
  end
end
