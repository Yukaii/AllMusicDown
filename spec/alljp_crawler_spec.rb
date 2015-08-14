require 'spec_helper'
require 'alljp_crawler'

describe AlljpCrawler do
  it "#crawl_entries" do
    entries = AlljpCrawler.get_entries
  end
end
