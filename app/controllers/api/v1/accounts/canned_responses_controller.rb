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
    @canned_response.images.purge if canned_response_params[:images].nil? && @canned_response.images.attached?
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
    params.permit(:short_code, :content, images: [], attachments: [])
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

      response_data[:images] = if response.images.attached?
                                response.images.map do |image|
                                  image_blob = image.blob
                                  {
                                    url: url_for(image),
                                    name: image_blob.filename.to_s,
                                    image_id: image.id,
                                    type: image_blob.content_type
                                  }
                                end
                              else
                                []
                              end

      response_data[:attachments] = if response.attachments.attached?
                                      response.attachments.map do |attachment|
                                        attachment_blob = attachment.blob
                                        {
                                          url: url_for(attachment),
                                          name: attachment_blob.filename.to_s,
                                          attachment_id: attachment.id,
                                          type: attachment_blob.content_type
                                        }
                                      end
                                    else
                                      []
                                    end

      response_data
    end
  end
end
