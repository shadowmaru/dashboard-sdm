require 'net/http'
require 'json'

# pass in limit: 5 to get the top 5 errors
def get_honeybadger_errors(options = {})
  api_token = "HgCM8bCTvdas2UWmuuRz:"
  project_id = options[:'project-id']

  url = "https://app.honeybadger.io/v2/projects/#{project_id}/faults?q=environment:production"
  if options[:order]
    url += "&order=#{options[:order]}"
  end

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(
    uri.request_uri,
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Basic #{(Base64.encode64(api_token)).strip}"
    })

  response = http.request(request)
  json_response = JSON.parse(response.body)

  upper_bound = options[:limit] || 5

  json_response['results'][0..(upper_bound - 1)]
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  # pass in your own limit, or let it default to 5
  top_five_faults = get_honeybadger_errors(order: "frequent")
  recent_five_faults = get_honeybadger_errors(order: "recent")

  send_event('most_freq_fault', {errors: top_five_faults})
  send_event('most_recent_fault', {errors: recent_five_faults})
end