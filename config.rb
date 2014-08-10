this_dir = File.dirname(__FILE__)
CONFIG = {
  :host          => ENV['RDB_HOST']  || 'localhost', 
  :port          => (ENV['RDB_PORT'] || '28015').to_i,
  :db            => ENV['RDB_DB']    || 'research',
  :library       => ENV['LIBRARY']   || 'library',
  :logdir        => ENV['LOGDIR']    || File.join(this_dir, 'logs')
}
