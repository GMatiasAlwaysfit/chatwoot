class Api::V1::Accounts::SlasController < Api::V1::Accounts::BaseController
  before_action :set_sla, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    @slas = Current.account.slas
    render json: @slas
  end

  def show
    render json: @sla
  end

  def create
    @sla = Current.account.slas.create!(sla_params)
  end

  def update
    @sla.update!(sla_params)
    render json: @sla
  end

  def destroy
    @sla.destroy!
    head :ok
  end

  private
    def set_sla
      @sla = Current.account.slas.find_by(id: params[:id])
    end

    def sla_params
      params.require(:sla).permit(:name, :alert_time, :limit_time, :max_time, :online, :account_id)
    end
end
