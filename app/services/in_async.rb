require 'open-uri'

class InAsync
  def find_all_followers(agent, followers_page, email, followers = [])
    next_page_link = followers_page.link_with(text: /avançar/)
    send_to_email(followers, email, 'followers') unless next_page_link

    followers_page = agent.click(next_page_link)

    followers = followers.concat(followers_from_page(agent, followers_page))

    find_all_followers(agent, followers_page, email, followers)
  end
  handle_asynchronously :find_all_followers

  private

  def send_to_email(result, email, template)
    binding.pry
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

  def logger
    Rails.logger
  end
end
