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

    next_page_link = followers_page.link_with(text: /avançar/)

    return unless next_page_link

    followers_page = agent.click(next_page_link)

    followers_from_page(agent, followers_page)
    find_all_followers(agent, followers_page)
  end

  def followers_from_page(agent, followers_page)
    threads = []
    followers_page.search('.feed-item').each do |item|
      threads << Thread.new do
        follower = {
          name: item.search('a')[1].text,
          title: item.search('.title').text,
          city: locations(item)[0],
          country: locations(item)[1],
          contact: contact(agent, item)
        }

        @followers << follower
      end
    end
    threads.each(&:join)
  end

  def contact(agent, item)
    follower_page = agent.click(item.search('a')[1])
    follower_page.search('#contact-comments-view').text
  end

  def locations(item)
    locations = item.search('.location').text.split(',')
    locations.length > 1 ? [locations[0], locations[1]] : ['', locations[0]]
  end

  def login(login_page, user, password)
    form = login_page.form

    form.session_key = user
    form.session_password = password

    form.submit
  end
end
