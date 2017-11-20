require 'open-uri'
require 'nokogiri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    html = File.read(index_url)
    flatiron = Nokogiri::HTML(html)
    flatiron.css("div.student-card").collect do |student|
      {name: student.css("h4").text,
       location: student.css("p.student-location").text,
       profile_url: student.css("a").attribute("href").value}
    end
  end

  def self.scrape_profile_page(profile_url)
    html = File.read(profile_url)
    student_page = Nokogiri::HTML(html)
    student_hash = {}

    page = student_page.css("div.social-icon-container")

    page.css("a").each do |social|
      key = social_parser(social.css("img.social-icon").attribute("src").value)
      key = "blog" if key == "rss"
      student_hash[key.to_sym] = social.attribute("href").value
    end
    student_hash[:profile_quote] = student_page.css("div.profile-quote").text
    student_hash[:bio] = student_page.css("div.description-holder p").text
    student_hash
  end

end

def social_parser(string)
  arr = string.split("/")
  site = arr.last
  return site[0..-10] if site.include?("-")
  site[0..-5]
end
