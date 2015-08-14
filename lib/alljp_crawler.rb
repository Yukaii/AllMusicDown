require 'httpclient'

require 'nokogiri'
require 'json'

require 'hashie'
require 'base64'

class AlljpCrawler
  attr_accessor :entries

  def initialize
    @clnt = HTTPClient.new
  end

  def get_entries
    # http://www.blogger.com/feeds/5116243093071042692/posts/summary?alt=json&start-index=2&max-results=1
    feed_response = Hashie::Mash.new JSON.parse(@clnt.get_content("http://www.alljpop.info/feeds/posts/summary?max-results=30&alt=json"))

    @entries = feed_response.feed.entry.map{|ent| AlljpEntry.new(ent)}

    @entries.each do |entry|

      Thread.new do
        doc = Nokogiri::HTML(@clnt.get_content entry.link)

        urls = doc.css('.sURL a:not(:first-child)').map do |a|
          [a[:id], Base64.decode64(URI(a[:href]).query.match(/(?<=url=).+/).to_s) ]
        end

        entry.download_links = Hash[ urls ]

        img = doc.css('#PostsContents img')[0]
        entry.cover_img = img && img[:src]
      end # end Thread

    end

    @entries
  end # end get_entries
end

class AlljpEntry
  attr_reader :id, :title, :summary, :link, :authors, :thumbnail, :published, :updated
  attr_accessor :download_links, :cover_img

  def initialize(mesh_entry)
    @title = mesh_entry.title["$t"]
    @summary = mesh_entry.summary["$t"]
    @authors = mesh_entry.author.map{|aut| aut.name["$t"]}
    @thumbnail = mesh_entry["media$thumbnail"].url

    lnk = mesh_entry.link.find{|l| l.rel == "alternate"}
    lnk && @link = lnk.href

    @id = mesh_entry.id["$t"]
    @published = mesh_entry.published["$t"]
    @updated = mesh_entry.updated["$t"]
  end
end
