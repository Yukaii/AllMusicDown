require 'httpclient'

require 'nokogiri'
require 'json'

require 'hashie'
require 'base64'

require 'thread'
require 'thwait'

module AlljpCrawler
  attr_accessor :entries

  def self.get_entries
    # http://www.blogger.com/feeds/5116243093071042692/posts/summary?alt=json&start-index=2&max-results=1
    feed_response = Hashie::Mash.new JSON.parse(clnt.get_content("http://www.alljpop.info/feeds/posts/summary?max-results=30&alt=json"))

    @entries = feed_response.feed.entry.map{|ent| AlljpEntry.new(ent)}

    threads = []
    @entries.each do |entry|

      threads << Thread.new do
        doc = Nokogiri::HTML(clnt.get_content entry.link)

        urls = doc.css('.sURL a:not(:first-child)').map do |a|
          [a[:id], Base64.decode64(URI(a[:href]).query.match(/(?<=url=).+/).to_s) ]
        end

        entry.download_links = Hash[ urls ]

        img = doc.css('#PostsContents img')[0]
        entry.cover_img = img && img[:src]
      end # end Thread

    end

    ThreadsWait.all_waits(*threads)
    @entries
  end # end get_entries

  def self.clnt
    @@http_client ||= HTTPClient.new
  end
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
