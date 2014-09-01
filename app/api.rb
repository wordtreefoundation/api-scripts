require 'sinatra'
require 'stalker'
require 'rethinkdb_job'
require_relative 'env'

rdb_config = CONFIG.select{ |k, v| [:host, :port, :db, :logdir].include? k }
$rjob = RethinkDBJob.new(rdb_config)

def enqueue_job(cmd, env={})
  $rjob.create.tap do |job_id|
    Stalker.enqueue('exec', "job_id" => job_id, "cmd" => cmd, "env" => env)
  end
end

get '/ok' do
  job_id = enqueue_job("ok")
  "<a href='status/#{job_id}/live'>#{job_id}</a>"
end

get '/count' do
  job_id = enqueue_job("count")
  "<a href='status/#{job_id}/live'>#{job_id}</a>"
end

get '/disk2db' do
  job_id = enqueue_job("disk2db")
  "<a href='status/#{job_id}/live'>#{job_id}</a>"
end

get '/status/:job_id' do
  content_type :json
  job_id = params[:job_id]
  job = $rjob.find(job_id)
  tail = $rjob.tail(job_id, Integer(params[:lines] || 30)).split("\n")
  status =
    if job["job_start"]
      if job["job_finish"]
        "finished"
      else
        "started"
      end
    else
      "not started"
    end
  job.merge(
    :status => status,
    :tail   => tail
  ).to_json
end

get '/status/:job_id/live' do
  erb :index, :locals => {:job_id => params[:job_id]}
end

__END__
@@ index
<html>
  <head>
    <title><%= job_id %> Job Status</title>
  </head>
  <body>
     <h2 style="margin: 2px 5px">Status of Job <span style="font-family:fixed"><%= job_id %></span></h2>
     <div style="margin:0.5ex; padding:1ex">Status: <span id="status" style="color:red;font-weight:bold"></span>
       <a href="../<%= job_id %>">more</a></div>
     <div id="msgs" style="line-height: 2ex; height: 62ex; background-color: #eee; padding: 1ex; margin: 0.5ex; border: 1px solid #bbb"></div>
  </body>

  <script type="text/javascript">
    function getXmlDoc() {
      return (window.XMLHttpRequest ?
        new XMLHttpRequest() :
        new ActiveXObject("Microsoft.XMLHTTP"));
    }

    function ajaxGet(url, callback) {
      var xmlDoc = getXmlDoc();

      xmlDoc.open('GET', url, true);

      xmlDoc.onreadystatechange = function() {
        if (xmlDoc.readyState === 4 && xmlDoc.status === 200) {
          callback(xmlDoc);
        }
      }

      xmlDoc.send();
    }

    window.onload = function(){
      var show = function(el){
        return function(msg){ el.innerHTML = msg; }
      };

      var show_msg = show(document.getElementById('msgs'));
      var show_status = show(document.getElementById('status'));

      var update = function() {
        var url = window.location.href.replace(/\/live$/, "");
        var callback = function(r) {
          var doc = JSON.parse(r.response);
          show_status(doc.status);
          show_msg(doc.tail.join("<br/>"));
        }
        ajaxGet(url, callback);
      };

      update();
      setInterval(update, 1000);
    }
  </script>
</html>