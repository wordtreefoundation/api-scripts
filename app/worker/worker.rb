require 'stalker'
require 'open3'
require 'fileutils'
require 'rethinkdb_job'
require_relative '../env'

include Stalker

def record_time(rjob, job_id, log, &block)
  # Record start of job
  now = Time.now
  rjob.set_timestamp(job_id, :job_start, now)
  log.puts "Job (#{$$}) started at: #{now}"
  log.flush

  yield
  log.flush

  # Record end of job
  now = Time.now
  rjob.set_timestamp(job_id, :job_finish, now)
  log.puts "Job finished at: #{now}"
  log.flush
end

def api_job(rjob, type='exec', &block)
  job(type) do |args|
    job_id = args["job_id"]
    $stderr.puts "Starting job #{job_id} (#{$$})"
    logfile = rjob.logfile(job_id)

    # Do it!
    FileUtils.mkdir_p(rjob.logdir)
    File.open(logfile, "a") do |log|
      record_time(rjob, job_id, log) do
        yield log, args
      end
    end
    $stderr.puts "Done job #{job_id}"
  end
end

$stdout.sync = true
$stderr.sync = true

rjob = RethinkDBJob.new(CONFIG)

require 'pty'

api_job(rjob) do |log, args|
  bin = File.join(File.dirname(__FILE__), "..", "scripts")
  env = (args["env"] || {}).merge \
    "RDB_HOST" => CONFIG[:host].to_s,
    "RDB_PORT" => CONFIG[:port].to_s,
    "RDB_DB"   => CONFIG[:db].to_s,
    "LIBRARY"  => CONFIG[:library].to_s,
    "LOGDIR"   => CONFIG[:logdir].to_s,
    "PATH"     => "#{bin}:#{ENV["PATH"]}"
  opts = {
    :unsetenv_others => true,
    :err => :out
  }
  spawn_args = [env] + Array(args["cmd"]) + [opts]
  begin
    PTY.spawn(*spawn_args) do |stdout, stdin, pid|
      begin
        stdout.each { |line| log.puts line; log.flush }
      rescue Errno::EIO
      end
    end
  rescue PTY::ChildExited
    msg = "The child process exited! #{spawn_args.inspect}"
    log.puts msg
    $stderr.puts msg
  end
end



