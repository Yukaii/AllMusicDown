class AlljpWorker
  include Sidekiq::Worker

  def perform
    AlljpCrawler.get_entries
  end
end
