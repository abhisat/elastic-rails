require 'elasticsearch'
require 'json'
class ApplicationController < ActionController::API
  #protect_from_forgery with: :exception

  def elastic_test
    $test = [1,2,4,5,6,5]
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
    $response = Hash.new
    $mainresponse = Array.new
    $urls = Array.new
    $totalhits = Array.new
    $labels = Array.new
    $before = data['before']
    $after = data['after']
    $interval = data['interval'].scan(/\d/).join('')
    $interval = $interval.to_i
    $interval = $interval * 60 * 1000 #assuming the time intervals is in minutes
    $hits = Array.new
    p(data['urls'])
    j = 0
    k = 0
    while j < data['urls'].length do
      begin
        $mainresponse[j] = client.search index: 'events',
                                         body: {query:
                                                    { query_string:
                                                          { query: data['urls'][j]}},
                                                range: {
                                                    derived_tstamp: {
                                                        gte: 10,
                                                        lte: 20,
                                                    }
                                                },
                                                aggs:
                                                    { by_page_views:
                                                         { date_histogram:
                                                               { field: "derived_tstamp",
                                                                 interval: "200m",
                                                                 min_doc_count: 1
                                                               }
                                                         }
                                                    }
                                         }
        $totalhits[j] = $mainresponse[j]['hits']['total']
        p("The response from " + data['urls'][j] + ":")
        p($mainresponse[j])
      rescue Exception => x
        $mainresponse[j] = "An error of type #{x.class} occurred."
        p("The response from " + data['urls'][j] + ":")
        p($response[j])
        $totalhits[j] = 0
      end
      # $urls[j] = data['urls'][j]
      # loop = $before.to_i
      # $temphits = Array.new

      # while loop <= $after.to_i
      #   loopbefore = $before.to_i
      #   loopafter = $before.to_i + $interval.to_i
      #
      #   begin
      #     temp = client.search index: 'events',
      #                          body: {query:
      #                                     { query_string:
      #                                           { query: data['urls'][j]}},
      #                                 aggs:
      #                                 {by_page_views:
      #                                     { date_histogram:
      #                                           {field: "derived_tstamp",
      #                                                  interval: "2m"
      #     }
      #     }
      #     }
      #                          }
      #     $response[$urls[j]] = temp
      #     $temphits.push(temp['hits']['total'])
      #     p("The response from " + data['urls'][j] + ":")
      #     p($response[$urls[j]])
      #   rescue Exception => x
      #     $response[$urls[j]] = "An error of type #{x.class} occurred."
      #     p("The response from " + data['urls'][j] + ":")
      #     p($response[$urls[j]])
      #     $temphits.push (0)
      #   end
      #   $labels.push(loop)
      #   loopbefore += $interval.to_i
      #   loopafter += $interval.to_i
      #   loop = loop + $interval.to_i
      #   k+=1
      #
      # end
      # $hits[j] = $temphits
      j+=1
    end
    #$labels = $labels.uniq
    render :elastic_test
  end
  end


