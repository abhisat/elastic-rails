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
        p(data['urls'])
        client.cluster.health
        i = 0
        response = Array.new
        while i<data['urls'].length do
          response[i] = client.search q: data['urls'][i]
          i+=1
        end
        render plain: response
    rescue
      render :elastic_test
    end
  end
end

