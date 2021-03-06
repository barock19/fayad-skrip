class Karyawan < ActiveRecord::Base
  ROLES = ['super_admin', 'director', 'human_resource', 'employee']
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :agama, :alamat, :jabatan_id, :kelamin, :city_id, :nama_lengkap, :nik, :npwp, :photo_url
  attr_accessible :tanggal_lahir, :tempat_lahir, :gaji_pokok, :roles
  
  belongs_to :jabatan
  has_many :absens
  has_many :holidays
  has_many :pendidikans
  has_many :pengalamen
  has_many :holydays  
  belongs_to :city
  has_many :gajis
  has_one :admin_user
  
  attr_accessible :login
  attr_accessor :login
  def photo_url
    read_attribute(:photo_url).nil? ? '/static.asset/anonymous_avatar.jpg' : read_attribute(:photo_url)
  end
  def holydays_taken_in_year
    holydays.where(:approved_at => (Time.now.beginning_of_year)..(Time.now.end_of_year), :approved => true).sum(:day_duration)
  end
  def self.g_new(hash)
    new_k = self.new(hash)
    new_k.uniq_nik
    new_k
  end
  def uniq_nik
    while true do
      c_nik = "%010d" % rand(99999999)
      break if Karyawan.find_by_nik(c_nik).nil?
    end
    self.password = c_nik.to_s
    self.nik = c_nik.to_s 
  end
  
  def name
    nama_lengkap
  end
  
  def is?(role)
    roles.include?(role.to_s)
  end
  
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end
  def role
    roles.first
  end
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
     if login = conditions.delete(:login)
       where(conditions).where(["lower(nik) = :value OR lower(email) = :value", { :value => login.downcase }]).first
     else
       where(conditions).first
     end
  end
  
  def absen_for_today
    absens.where("absen_for = :absen_for", :absen_for => Time.now.to_date).last
  end
  def is_masuk_for_today?
    a = absen_for_today
    a.nil? ? false : a.status == "MASUK" 
  end
  def have_workoff_for_today?
    a = absen_for_today
    if !a.nil? and a.status == "MASUK"
      a.real_time_earn.nil? == false
    else
      false
    end
  end
end
