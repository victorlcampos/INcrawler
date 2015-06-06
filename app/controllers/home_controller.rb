class HomeController < ApplicationController
  before_filter :init_linkedin, except: :index

  def index
  end

  def followers
    @result = @linkedin.followers(params[:company_id])
    redirect_to root_path, notice: 'Um email com o Excel será enviado para você'
  end

  def analitics
    @result = @linkedin.analitic(params[:company_id])
    redirect_to root_path, notice: 'Um email com o Excel será enviado para você'
  end

  private

  def init_linkedin
    @linkedin = In.new(params[:user], params[:password], params[:email])
  end
end
