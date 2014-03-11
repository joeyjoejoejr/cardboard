module Cardboard
  class Url < ActiveRecord::Base
    belongs_to :urlable, polymorphic: true

    serialize :slugs_backup, Array

    before_save :update_slugs_backup

    validates :path, presence: true
    validates :slug, uniqueness: { :case_sensitive => false, :scope => :path }, presence: true



    def self.root
      # Homepage is the highest position in the root path
      where(path: "/").rank(:position).first
    end
    def root?
      Url.root.id == self.id 
    end

    def self.urlable_for(full_url)
      return nil unless full_url
      path, slug = self.path_and_slug(full_url)
      page = self.where(path: path, slug: slug).first

      if slug && page.nil?
        #use arel instead of LIKE/ILIKE
        page = self.where(path: path).where(self.arel_table[:slugs_backup].matches("% #{slug}\n%")).first
        page.using_slug_backup = true if page
      end

      page.try(:urlable)
    end

    def slug=(value)
      # the user can overwrite the auto generated slug
      self[:slug] = value.present? ? value.to_url : nil
    end

    def using_slug_backup?
      @using_slug_backup || false
    end

    def using_slug_backup=(value)
      @using_slug_backup = value
    end

    def is_root=(val)
      self.sort_order_position = :first if val
    end
    
    # def to_param
    #   "#{id}-#{slug}"
    # end  

    def to_s
      return "/" if slug.blank?
      "#{path}#{slug}/"
    end

  private
    def self.path_and_slug(full_url)
      *path, slug = full_url.sub(/^\//, '').split('/')
      [path.blank? ? '/' : "/#{path.join('/')}/", slug]
    end


    def update_slugs_backup
      return nil if !self.slug_changed? || self.slug_was.nil?
      self.slugs_backup |= [self.slug_was] #Yes, that's a single pipe...
    end

  end
end