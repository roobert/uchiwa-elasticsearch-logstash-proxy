#!/usr/bin/env ruby
#
# about:
#
# this script takes an http request with host parameter and forwards
# the query to elasticsearch, it then returns the result in a predefined
# format which can be used in an iframe.
#
# example result:
#
#
#                   "tags" => [ [0] "sensu-ALERT" ],
#                "message" => "CheckDisk CRITICAL: / 98%\n",
#                   "host" => "sugar",
#              "timestamp" => 1415538575,
#                "address" => "10.0.1.90",
#             "check_name" => "check-disk",
#                "command" => "/etc/sensu/plugins/check-disk.rb",
#                 "status" => 2,
#               "flapping" => nil,
#            "occurrences" => 1680,
#                 "action" => "create"
#

require 'rubygems'
require 'sinatra'
require 'elasticsearch'
require 'json'
require 'awesome_print'
require 'haml'
require 'ap'
require 'pp'
require 'yaml'

set :protection, :except => :frame_options
set :ugly, true

helpers do
  def check_params
    return "please specify ?host=" unless params[:host]
  end

  def client
    @client ||= Elasticsearch::Client.new(
      log: true,
      host: 'elasticsearch.example.com',
      port: 9200
    )
  end

  def query
    { match: { host: params[:host] } }
  end

  def results
    client.search( index: 'logstash-*', body: { query: query })['hits']['hits']
  end

  def truncate(message)
    message[0..100].chomp("\n")
  end

  def get_content
    @content = results.map do |result|
      [
        "#{result['_source']['@timestamp']}",
        "(#{result['_source']['status']})",
        "[#{result['_source']['check_name']}]",
        truncate(result['_source']['@timestamp']),
      ].join(' ')
    end
  end
end

get '*' do
  check_params(params)

  get_content

  haml :content
end
