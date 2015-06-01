class HomeController < ApplicationController
  before_filter :init_linkedin, except: :index

  def index
  end

  def followers
    @result = @linkedin.followers(params[:company_id])
  end

  def analitics
    @result = @linkedin.analitic(params[:company_id])
  end

  private

  def init_linkedin
    @linkedin = In.new(params[:user], params[:password])
  end
end
