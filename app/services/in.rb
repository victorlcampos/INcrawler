require 'open-uri'

class In
  attr_accessor :user, :password, :email

  def initialize(user, password, email)
    @user = user
    @password = password
    @email = email
  end

  def followers(company_id)
    agent = Mechanize.new { |a| a.follow_meta_refresh = true }

    agent.get("https://www.linkedin.com/uas/login?session_redirect=https%3A%2F%2Fwww%2Elinkedin%2Ecom%2Fcompany%2F#{company_id}%2Ffollowers&fromSignIn=") do |login_page|
      logger.info 'Login Page'
      followers_page = login(login_page)

      find_all_followers(agent, followers_page, @email)
    end
  end
  handle_asynchronously :followers

  def analitic(company_id)
    agent = Mechanize.new { |a| a.follow_meta_refresh = true }
    analitics = []

    agent.get("https://www.linkedin.com/uas/login?session_redirect=https%3A%2F%2Fwww%2Elinkedin%2Ecom%2Fcompany%2F#{company_id}%2Fanalytics%3Ftrk%3Dtop_nav_analytics&fromSignIn=") do |login_page|
      logger.info 'Login Page'
      analitic_page = login(login_page)
      company_number = analitic_page.body.match("company=([1-9]*)")[1]
      analitics << find_updates(agent, company_number)
      analitics << find_hyc(agent, company_number)
    end

    send_to_email(analitics, @email, 'analitics')
  end
  handle_asynchronously :analitic

  private

  def find_all_followers(agent, followers_page, email, followers = [])
    next_page_link = followers_page.link_with(text: /avançar/)

    return send_to_email(followers, email, 'followers') unless next_page_link
    followers_page = agent.click(next_page_link)

    followers = followers.concat(followers_from_page(agent, followers_page))

    find_all_followers(agent, followers_page, email, followers)
  end

  def send_to_email(result, email, template)
    LinkedinMailer.export(result, email, template).deliver_now
  end

  def followers_from_page(agent, followers_page)
    Parallel.map(followers_page.search('.feed-item')) do |item|
      follower = {
        name: item.search('a')[1].text,
        title: item.search('.title').text,
        city: locations(item)[0],
        country: locations(item)[1],
        contact: contact(agent, item)
      }

      follower
    end
  end

  def contact(agent, item)
    follower_page = agent.click(item.search('a')[1])
    follower_page.search('#contact-comments-view').text
  end

  def locations(item)
    locations = item.search('.location').text.split(',')
    locations.length > 1 ? [locations[0], locations[1]] : ['', locations[0]]
  end

  def find_updates(agent, company_number)
    updates = []
    agent.get("https://www.linkedin.com/biz/#{company_number}/analytics/statusUpdatesTable?pathWildcard=#{company_number}&start=0&count=100000000&trk=") do |update_page|
      Nokogiri::HTML(update_page.content).css(".single-update").each do |item|
        updates << {
          preview: item.css('.preview').first.text,
          date: item.css('.date').first.text,
          audience: item.css('.audience').first.text,
          impressions: item.css('.impressions').first.text,
          clicks: item.css('.clicks').first.text,
          interactions: item.css('.social-actions').first.text,
          followers_acquired: item.css('.followers-acquired').first.text,
          engagement: item.css('.engagement').first.text
        }
      end
    end
    updates
  end

  def find_hyc(agent, company_number)
    companies = []
    agent.get("https://www.linkedin.com/company/_internal/mappers/analyticsFollowerHyc?companyId=#{company_number}") do |hyc_page|
      companies.concat(JSON.parse(hyc_page.content)["content"]["biz_analytics_follower_hyc"]["companies"])
      companies.each do |company|
        company.delete("i18n_analytics_follower_view")
        company.delete("fmtAuto_number_1")
        company.delete("isCurrentCompany")
        company.delete("squareLogoId")
        company["company_logo"] = company.delete("_company_logo")["media_picture_link_400"]
      end
    end
    companies
  end

  def login(login_page)
    logger.info 'Login'
    form = login_page.form

    form.session_key = @user
    form.session_password = @password

    form.submit
  end

  def logger
    Rails.logger
  end
end
