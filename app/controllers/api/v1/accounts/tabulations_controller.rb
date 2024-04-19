class Api::V1::Accounts::TabulationsController < Api::V1::Accounts::BaseController
  before_action :set_tabulation, only: [:show, :update, :destroy]

  def index
    @tabulations = Current.account.tabulations
    render json: @tabulations
  end

  def show
    render json: @tabulation
  end

  def create
    @tabulation = Current.account.tabulations.create!(tabulation_params)
    head :ok
  end

  def update
    @tabulation.update!(tabulation_params)
    render json: @tabulation
  end

  def destroy
    @tabulation.destroy!
    head :ok
  end

  private

  def set_tabulation
    @tabulation = Current.account.tabulations.find_by(id: params[:id])
  end

  def tabulation_params
    params.require(:tabulation).permit(:name, :description, :end_phrase, :tab_type)
  end
end
