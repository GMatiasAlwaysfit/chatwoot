# == Schema Information
#
# Table name: transfers_sessions
#
#  id                     :uuid             not null, primary key
#  id_session_destination :uuid             not null
#  id_session_origin      :uuid             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class TransfersSession < ApplicationRecord
  belongs_to :agent_session_origin, class_name: "AgentSession", foreign_key: "id_session_origin"
  belongs_to :agent_session_destination, class_name: "AgentSession", foreign_key: "id_session_destination"
end
