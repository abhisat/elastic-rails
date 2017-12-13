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
    data = JSON.parse(request.body.string)
    response = Array.new
    $hits = Array.new
    i = 0
    while i < data['urls'].length do
      begin
        response[i] = client.search q: data['urls'][i]
        $hits[i] = response[i]['hits']['total']
      rescue
      response[i] = ""
      $hits[i] = 0
      end
      i+=1
    end
    render plain: $hits
  end
end

