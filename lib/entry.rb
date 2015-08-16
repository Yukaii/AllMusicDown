class Entry
  include Mongoid::Document

  field :_id, type: String
  field :title, type: String
  field :summary, type: String
  field :link, type: String
  field :authors, type: Array
  field :thumbnail, type: String
  field :published, type: String
  field :updated, type: String
  field :download_links, type: Hash
  field :cover_img, type: String
  field :direct_links, type: Hash

  def from_mesh(mesh_entry)
    self.title = mesh_entry.title["$t"]
    self.summary = mesh_entry.summary["$t"]
    self.authors = mesh_entry.author.map{|aut| aut.name["$t"]}
    self.thumbnail = mesh_entry["media$thumbnail"].url

    lnk = mesh_entry.link.find{|l| l.rel == "alternate"}
    lnk && self.link = lnk.href

    self._id = mesh_entry.id["$t"]
    self.published = mesh_entry.published["$t"]
    self.updated = mesh_entry.updated["$t"]

    self
  end
end
