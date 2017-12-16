require 'elasticsearch'
require 'json'
class ApplicationController < ActionController::API

  def page_views

    # Code for connecting the rails API to the Elastic Search server
    client = Elasticsearch::Client.new transport_options: {
        request: { timeout: 10000 },
    }, retry_on_failure: true, hosts:[
            { host: 'test.es.streem.com.au',
              port: '9200',
              user: 'elastic',
              password: 'streem'

        }], log: true, reload_connections: true
    # Code for connecting the rails API to the Elastic Search server

    # Code to parse the GET request body to JSON and handle an exception if thrown while parsing.
    begin
      data = JSON.parse(request.body.string)
    rescue
      render plain: "Error in parsing request body."
      return
    end
    # Code to parse the GET request body to JSON and handle an exception if thrown while parsing.

    # mainResponse array stores the responses returned for each url aggregation query on elastic search
    $mainResponse = Array.new

    # totalHits array stores the total number of hits for each url aggregation query on elastic search
    $totalHits = Array.new

    j = 0

    # WHILE loop to do histogram aggregation query on each url in the urls array in request body
    while j < data['urls'].length do
      begin
        $mainResponse[j] = client.search index: 'events',
                                         body: {
                                             query: {
                                                 bool: {
                                                     must: [
                                                         {
                                                             query_string: {
                                                                 query: data['urls'][j]
                                                             }
                                                         },
                                                         {
                                                             range: {
                                                                 derived_tstamp: {
                                                                     gte: data['before'],
                                                                     lte: data['after']
                                                                 }
                                                             }
                                                         }
                                                     ]
                                                 }
                                             },
                                             aggs:
                                                 { by_page_views:
                                                       { date_histogram:
                                                             { field: "derived_tstamp",
                                                               interval: data['interval'],
                                                             }
                                                       }
                                                 }
                                         }
        $totalHits[j] = $mainResponse[j]['hits']['total']
        p("The response from " + data['urls'][j] + ":")
        p($mainResponse[j])

      # Handle exception while parsing each url query and print out the exception to console
      rescue Exception => x
        $mainResponse[j] = "An error of type #{x.class} occurred."
        $totalHits[j] = 0
        p("The response from " + data['urls'][j] + ":")
        p($mainResponse[j])
      end
      j+=1
    end
    # WHILE loop to do histogram aggregation query on each url in the urls array in request body

    # Return the responses for each url aggregation query in JSON
    render json: $mainResponse
  end
  end


