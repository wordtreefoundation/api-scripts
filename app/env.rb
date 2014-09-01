
default_logdir = File.join(File.dirname(__FILE__), '..', 'log')

CONFIG = {
  :host          => ENV['RDB_HOST']  || 'localhost', 
  :port          => (ENV['RDB_PORT'] || '28015').to_i,
  :db            => ENV['RDB_DB']    || 'research',
  :library       => ENV['LIBRARY']   || 'library',
  :logdir        => ENV['LOGDIR']    || default_logdir
}