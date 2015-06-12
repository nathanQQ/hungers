class Listing < ActiveRecord::Base
  acts_as_paranoid
  
  if Rails.env.development?
  	has_attached_file 	:image, :styles => { :medium => "100x100>", :thumb => "100x100>" }, :default_url => "no-image.jpg"
  else
    has_attached_file   :image, :styles => { :medium => "100x100>", :thumb => "100x100>" }, :default_url => "no-image.jpg",
              :storage => :s3,
              :s3_credentials => Rails.root.join("config/aws.yml"),
              :path => ":styles/:id_:filename",
              :bucket => "hungersme",
              :s3_host_name => "s3-us-west-1.amazonaws.com"
  end
  
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator, :attributes => :image, :less_than => 1.megabytes
  validates :name, :price, :description, :sold_date, presence: true
  validates :price, numericality: {greater_than: 0}	

  has_many :orders
  belongs_to :seller

  paginates_per 8
  acts_as_votable
end
