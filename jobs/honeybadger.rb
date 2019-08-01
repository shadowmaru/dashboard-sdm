require 'net/http'
require 'json'

# pass in limit: 5 to get the top 5 errors
def get_honeybadger_errors(options = {})
  api_token = ENV['HONEYBADGER_TOKEN']
  project_id = options[:project_id]

  url = "https://app.honeybadger.io/v2/projects/#{project_id}/faults?q=environment:production"
  url += "&order=#{options[:order]}" if options[:order]

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(
    uri.request_uri,
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Basic #{Base64.encode64(api_token).strip}"
    })

  response = http.request(request)
  json_response = JSON.parse(response.body)

  upper_bound = options[:limit] || 5

  json_response['results'][0..(upper_bound - 1)]
end

def send_errors(project, name)
  top_five_faults = get_honeybadger_errors(project_id: project, order: "frequent")
  recent_five_faults = get_honeybadger_errors(project_id: project, order: "recent")

  send_event("#{name}_freq", errors: top_five_faults)
  send_event("#{name}_rec", errors: recent_five_faults)
end

SCHEDULER.every '15m', first_in: 0 do |_job|
  send_errors(34466, 'nps')
  send_errors(43945, 'auth')

  # top_five_faults = get_honeybadger_errors(project_id: '34466', order: "frequent")
  # recent_five_faults = get_honeybadger_errors(project_id: '34466', order: "recent")

  # send_event('nps_freq', errors: top_five_faults)
  # send_event('nps_rec', errors: recent_five_faults)
end
