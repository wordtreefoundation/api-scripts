
CONFIG = {
  :host          => ENV['RDB_HOST']  || 'localhost', 
  :port          => (ENV['RDB_PORT'] || '28015').to_i,
  :db            => ENV['RDB_DB']    || 'research',
  :library       => ENV['LIBRARY']   || 'library',
  :logdir        => ENV['LOGDIR']    || File.join(File.dirname(__FILE__), '..', 'log')
}

ENV['BEANSTALK_URL'] ||= "beanstalk://#{ENV['BEANSTALKD'] || 'localhost'}:11300/"