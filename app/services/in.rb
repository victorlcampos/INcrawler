require 'open-uri'

class In
  def followers(user, password, company_id)
    agent = Mechanize.new { |a| a.follow_meta_refresh = true }
    @followers = []

    agent.get("https://www.linkedin.com/uas/login?session_redirect=https%3A%2F%2Fwww%2Elinkedin%2Ecom%2Fcompany%2F#{company_id}%2Ffollowers&fromSignIn=") do |login_page|
      followers_page = login(login_page, user, password)
      find_all_followers(agent, followers_page)
    end

    export_to_excel(@followers) unless @followers.blank?

    @followers
  end

  private

  def export_to_excel(result)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'result') do |sheet|
        sheet.add_row result.first.keys
        result.each do |follower|
          sheet.add_row follower.values
        end
      end
      p.serialize('results.xlsx')
    end
  end

  def find_all_followers(agent, followers_page)
    p @followers.count

    next_page_link = followers_page.link_with(:text => /avançar/)

    return unless next_page_link

    followers_page = agent.click(next_page_link)

    followers_from_page(followers_page)
    find_all_followers(agent, followers_page)
  end

  def followers_from_page(followers_page)
    followers_page.search('.feed-item').each do |item|
      follower = {}

      follower[:name] = item.search('a')[1].text
      follower[:title] = item.search('.title').text
      follower[:city] = item.search('.location').text.split(',')[0]
      follower[:country] = item.search('.location').text.split(',')[1]

      @followers << follower
    end
  end

  def login(login_page, user, password)
    form = login_page.form

    form.session_key = user
    form.session_password = password

    form.submit
  end
end
