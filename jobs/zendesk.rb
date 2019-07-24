require 'zendesk_api'

client = ZendeskAPI::Client.new do |config|
  config.url = "https://bioritmo.zendesk.com/api/v2"
  config.username = "ricardo.yasuda@bioritmo.com.br"
  config.token = "RG6dTozlnGyH1xTjNdnHiFozZPIuRJ0w8zDSMIuI"
  config.retry = true
end

# array of view IDs to check, these are your data-id's in your erb file.
views = [35074546]

SCHEDULER.every '10m', first_in: 0 do |job|
  counts = client.view_counts(ids: views, path: 'views/count_many')
  counts.all do |ct|
    if ct.fresh
      send_event(ct.view_id.to_i, { current: ct.value.to_i })
    end
  end
end