require 'sinatra'
require 'stalker'
require_relative 'rethinkdb_job'
require_relative 'config'

rjob = RethinkDBJob.new(CONFIG[:host], CONFIG[:port], CONFIG[:db])

get '/test' do
  Stalker.enqueue('test.thing', "job_id" => rjob.create)
  "enqueued"
end

