class Profile < ActiveRecord::Base

  belongs_to :user

  validates  :directories, presence: true
  validates  :directories, uniqueness: true

  before_create :backup
  after_destroy :clean_contents

  def backup
    # system("sudo -S chmod -R 777 /home/angga/Videos/") if cannot access folder
    ff = self.exclusions.split(",").map{|x| "--exclude='#{x}'"}.join(" ")
    # system("rsync -avz #{ff} /home/angga/Pictures/ #{self.directories}") # for me to test
    system("rsync -avz #{ff} /home/ #{self.directories}")
  end

  def clean_contents
    directory = !self.directories.strip[-1].eql?("/") ? (self.directories.strip + "/*") : (self.directories.strip + "*")
    return system("rm -rf #{directory}")
  end

  def self.detail(directories)
    contents = []
    total_size = IO.popen("du -sh #{directories.split("/").join("/")}/").readlines.first
    directory = !directories.strip[-1].eql?("/") ? (directories.strip + "/*") : (directories.strip + "*")
    Dir.glob(directory).each do |file|
      unless File.directory? file
        detail_file = File.stat("#{file}")
        detail_file
        contents << {type: "file", name: file.split("/").last, size: detail_file.size, create_at: detail_file.ctime}
      else
        contents << {type: "directory", name: file.split("/").last, directory: file }
      end
    end
    return [total_size ,contents.sort_by{ |k,v| k[:type]}]
  end

  def self.delete_file(directory, file)
    current_directory = directory.split("/")
    file_path = current_directory << file
    system("rm -rf '#{file_path.join("/")}'")
  end
end
