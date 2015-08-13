require 'spec_helper'
require 'alljp_crawler'

describe AlljpCrawler do
  let(:crawler) { AlljpCrawler.new }

  it "#crawl_entries" do
    crawler.get_entries
  end
end
