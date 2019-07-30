require 'net/http'
require 'json'

def flowclimate_cmd(options = {})
  api_token = ENV['FLOWCLIMATE_API_TOKEN']
  team_id = options[:team_id]

  url = ENV['FLOWCLIMATE_URL'] + "/teams/#{team_id}/average_demand_cost"

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = false
  request = Net::HTTP::Get.new(
    uri.request_uri,
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'api_token' => api_token
    }
  )

  response = http.request(request)

  JSON.parse(response.body)
end

SCHEDULER.every '60m', first_in: 0 do |_job|
  cmd = flowclimate_cmd(team_id: ENV['FLOWCLIMATE_TEAM_ID'])

  send_event('flowclimate-team-name', title: cmd['data']['team_name'], text: cmd['message'])

  send_event(
    'cmdCurrent',
    title: 'Semana Atual',
    current: cmd['data']['current_week'],
    last: cmd['data']['last_week'],
  )
  send_event('cmdLast', title: 'Última Semana', current: cmd['data']['last_week'])
end
