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
    handle_images_update
    handle_attachments_update

    @canned_response.update!(canned_response_params.except(:no_image_alteration, :no_attachment_change, :images, :attachments))
    render json: @canned_response
  end

  def destroy
    @canned_response.destroy!
    head :ok
  end

  private

  def handle_images_update
    if canned_response_params.key?(:images)
      if canned_response_params[:images].present? && !params.key?(:no_image_alteration)
        @canned_response.images.purge
        @canned_response.images.attach(canned_response_params[:images])
      end
      canned_response_params.delete(:images)
    else
      @canned_response.images.purge
    end
  end

  def handle_attachments_update
    if canned_response_params.key?(:attachments)
      if canned_response_params[:attachments].present? && !params.key?(:no_attachment_change)
        @canned_response.attachments.purge
        @canned_response.attachments.attach(canned_response_params[:attachments])
      end
      canned_response_params.delete(:attachments)
    else
      @canned_response.attachments.purge
    end
  end

  def fetch_canned_response
    @canned_response = Current.account.canned_responses.find(params[:id])
  end

  def canned_response_params
    params.permit(:short_code, :content, :no_image_alteration, :no_attachment_change, images: [], attachments: [])
  end

  def canned_responses
    canned_responses = if params[:search]
                         Current.account.canned_responses
                                .where('short_code ILIKE :search OR content ILIKE :search', search: "%#{params[:search]}%")
                                .order_by_search(params[:search])
                       else
                         Current.account.canned_responses
                       end

    handle_response_data(canned_responses)
  end

  def handle_response_data(canned_responses)
    canned_responses.map do |response|
      response_data = response.attributes

      response_data[:images] = if response.images.attached?
                                 handle_images_response(response)
                               else
                                 []
                               end

      response_data[:attachments] = if response.attachments.attached?
                                      handle_attachments_response(response)
                                    else
                                      []
                                    end

      response_data
    end
  end

  def handle_images_response(response)
    response.images.map do |image|
      image_blob = image.blob
      {
        url: url_for(image),
        name: image_blob.filename.to_s,
        image_id: image.id,
        type: image_blob.content_type
      }
    end
  end

  def handle_attachments_response(response)
    response.attachments.map do |attachment|
      attachment_blob = attachment.blob
      {
        url: url_for(attachment),
        name: attachment_blob.filename.to_s,
        attachment_id: attachment.id,
        type: attachment_blob.content_type
      }
    end
  end
end
