class Api::V1::Accounts::CannedResponsesController < Api::V1::Accounts::BaseController
  before_action :fetch_canned_response, only: [:update, :destroy]

  def index
    render json: canned_responses
  end

  def create
    @canned_response = Current.account.canned_responses.new(canned_response_params)
    @canned_response.save!
    render json: @canned_response
  end

  def update
    @canned_response.image.purge if canned_response_params[:image].nil? && @canned_response.image.attached?
    @canned_response.attachments.purge if canned_response_params[:attachments].nil? && @canned_response.attachments.attached?

    @canned_response.update!(canned_response_params)
    render json: @canned_response
  end

  def destroy
    @canned_response.destroy!
    head :ok
  end

  private

  def fetch_canned_response
    @canned_response = Current.account.canned_responses.find(params[:id])
  end

  def canned_response_params
    params.permit(:short_code, :content, :image, attachments: [])
  end

  def canned_responses
    canned_responses = if params[:search]
                         Current.account.canned_responses
                                .where('short_code ILIKE :search OR content ILIKE :search', search: "%#{params[:search]}%")
                                .order_by_search(params[:search])
                       else
                         Current.account.canned_responses
                       end

    canned_responses.map do |response|
      response_data = response.attributes

      if response.image.attached?
        image_blob = response.image.blob
        response_data[:image_url] = url_for(response.image)
        response_data[:image_name] = image_blob.filename.to_s
        response_data[:image_id] = response.image.id
      end

      response_data[:attachments] = if response.attachments.attached?
                                      response.attachments.map do |attachment|
                                        attachment_blob = attachment.blob
                                        {
                                          attachment_url: url_for(attachment),
                                          name: attachment_blob.filename.to_s,
                                          attachment_id: attachment.id
                                        }
                                      end
                                    else
                                      []
                                    end

      response_data
    end
  end
end
