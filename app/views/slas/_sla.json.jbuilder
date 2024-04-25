json.extract! sla, :id, :name, :alert_time, :limit_time, :max_time, :online, :account_id, :created_at, :updated_at
json.url sla_url(sla, format: :json)
