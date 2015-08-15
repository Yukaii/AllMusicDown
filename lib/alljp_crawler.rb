require 'httpclient'

require 'nokogiri'
require 'json'

require 'hashie'
require 'base64'

require 'thread'
require 'thwait'

require 'rtesseract'

module AlljpCrawler
  attr_accessor :entries

  def self.get_entries
    # http://www.blogger.com/feeds/5116243093071042692/posts/summary?alt=json&start-index=2&max-results=1
    feed_response = Hashie::Mash.new JSON.parse(clnt.get_content("http://www.alljpop.info/feeds/posts/summary?max-results=50&alt=json"))

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

        entry.download_links.each do |_tpe, _lnk|
          entry.direct_links ||= {}
          entry.direct_links.merge!(resolve_download(_tpe, _lnk))
        end
      end # end Thread

    end

    ThreadsWait.all_waits(*threads)
    # binding.pry
    @entries
  end # end get_entries

  def self.clnt
    @@http_client ||= HTTPClient.new
  end

  def self.resolve_download type, link
    case type
    when 'UC'
      return {}
    when 'MC'
      return {} unless link.match(/www\.mirrorcreator\.com/)
      r = clnt.get_content link
      code = r.match(/(?<=\"\/mstat.php\?)[^"]+/).to_s
      url = "http://www.mirrorcreator.com/mstat.php?#{code}"
      doc = Nokogiri::HTML(clnt.get_content url)

      links_hash = doc.xpath('//table/tr[position()>1]').inject({}) do |h, tr|
        result_h = {}
        stat = tr.css('td.stat img')[0][:alt]

        if stat == 'Success'
          host = tr.css('td.host img')[0][:alt]
          dlnk = "http://www.mirrorcreator.com#{tr.css('td.dl_link a')[0][:href]}"
          direct_link = Nokogiri::HTML(clnt.get_content dlnk).css('#redirectlink a')[0][:href]

          result_h = { host => direct_link }
        end
        h.merge(result_h)
      end

      return links_hash
    when 'EU'

      # doc = Nokogiri::HTML(clnt.get_content link)
      # code = URI(link).query.match(/(?<==).+/).to_s
      # eu_regex = /www.embedupload.com\/\?(?<pvd>.+)\=#{code}/

      # if !doc.css('input[name="capcode"]').empty?
      #   img_name = "#{SecureRandom.uuid}.jpg"
      #   File.write(File.join('tmp', img_name), clnt.get_content(URI.join(link, 'lib/CaptchaSecurityImages.php')))
      #   img = RTesseract.new(File.join('tmp', img_name), options: :digits)
      #   capcode = img.to_s.gsub(/[^\d]/, '')
      # else
      #   dls = doc.xpath('//a/@href').map(&:to_s).select{|_lnk| _lnk.match(eu_regex)}.map do |_link|
      #     provider = _link.match(eu_regex)[:pvd]
      #     direct_link = Nokogiri::HTML(clnt.get_content _link).xpath('//div[@class="categories"]/span/b/a/@href').to_s
      #     binding.pry
      #     [provider, direct_link]
      #   end
      #   binding.pry
      #   return Hash[ dls ]
      # end
      # capcode:20026
    else
    end

    {}
  end

end

class AlljpEntry
  attr_reader :id, :title, :summary, :link, :authors, :thumbnail, :published, :updated
  attr_accessor :download_links, :cover_img, :direct_links

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
