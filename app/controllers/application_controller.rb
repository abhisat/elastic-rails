require 'elasticsearch'
require 'json'
class ApplicationController < ActionController::API
  #protect_from_forgery with: :exception

  def elastic_test
    client = Elasticsearch::Client.new transport_options: {
        request: { timeout: 10000 },
    }, retry_on_failure: true, hosts:[
        { host: 'test.es.streem.com.au',
          port: '9200',
          user: 'elastic',
          password: 'streem'

        }], log: true, reload_connections: true
    begin
      data = JSON.parse(request.body.string)
    rescue
      render :elastic_test
      return
    end

    $response = Array.new
    $urls = Array.new
    $before = data['before']
    $after = data['after']
    $interval = data['interval'].scan(/\d/).join('')
    $interval = $interval.to_i
    $interval = $interval * 60 * 1000 #assuming the time intervals is in minutes
    $hits = Array.new
    
    i = 0
    while i < data['urls'].length do
      begin
        $response[i] = client.search index: "events", body: { query: { range: { derived_tstamp:{"gte": $before, "lte": $after } } } }
        $urls[i] = data['urls'][i]
        $hits[i] = $response[i]['hits']['total']
        p("The response from " + data['urls'][i] + ":")
        p($response[i])
      rescue Exception => x
        $response[i] = "An error of type #{x.class} occurred."
        p("The response from " + data['urls'][i] + ":")
        p($response[i])
        $hits[i] = 0
      end
      i+=1
    end

    render :elastic_test
  end
  end


