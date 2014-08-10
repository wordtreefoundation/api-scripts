require 'rethinkdb'

class RethinkDBJob
  def initialize(host, port, db, table="jobs")
    @r = RethinkDB::RQL.new

    setup_rethinkdb(host, port, db, table)

    @table = table
    @rdb = @r.connect(
      :host => host,
      :port => port,
      :db   => db)
  end

  def setup_rethinkdb(host, port, db, table)
    begin
      connection = @r.connect(:host => host, :port => port)
    rescue Exception => err
      $stderr.puts "Cannot connect to RethinkDB database " +
                   "#{host}:#{port} (#{err.message})"
      Process.exit(1)
    end

    begin
      @r.db_create(db).run(connection)
    rescue RethinkDB::RqlRuntimeError => err
      $stderr.puts "Database `#{db}` already exists."
    end

    begin
      @r.db(db).table_create(table).run(connection)
    rescue RethinkDB::RqlRuntimeError => err
      $stderr.puts "Table `#{table}` already exists."
    ensure
      connection.close
    end
  end

  def create
    result = @r.table(@table).insert({}, :return_vals => true).run(@rdb)
    if result["inserted"] == 1
      result["new_val"]["id"]
    else
      raise "Unable to create new job record"
    end
  end

  def set_timestamp(job_id, column, time=Time.now)
    @r.table(@table).get(job_id).update(column => time).run(@rdb)
  end
end