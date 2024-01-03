require 'rufus-scheduler'
require 'git'

# You can customize the aria2 config path by modifying this variable
$custom_aria2_conf_path = ''

def pull_trackers_list_repo
  if Dir.foreach('./').include?('trackerslist')
    g = Git.init './trackerslist'
    g.pull
    puts "lastest commit date: " + g.object('HEAD^').date.to_s
  else
    trackers_list_repo_url = 'https://github.com/ngosang/trackerslist.git'
    puts "cloning trackers list repo"
    g = Git.clone(trackers_list_repo_url)
  end
end

def write_latest_trackers
  default_aria2_conf_path = Dir.home + '/.aria2/aria2.conf'
  aria2_conf_path = $custom_aria2_conf_path != '' ? $custom_aria2_conf_path : default_aria2_conf_path
  bt_tracker_reg = /^(bt-tracker=)(((https?|udp):\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})((:[0-9]{1,4})?)([\/\w\, \.-]*)*\/?)*$/
  latest_trackers = []
  File.open('./trackerslist/trackers_best.txt', 'r').each_line do |line|
    if line.length > 1
      latest_trackers.push(line.gsub("\n", ""))
    end
  end
  bt_trakcer_value = latest_trackers.join(',')
  File.write(aria2_conf_path, File.read(aria2_conf_path).sub(bt_tracker_reg, "bt-tracker=#{bt_trakcer_value}"))
  puts 'bt-tracker update succcess'
end

def update_trackers
  pull_trackers_list_repo
  write_latest_trackers
end

scheduler = Rufus::Scheduler.new

scheduler.every '1d' do
  update_trackers
end

update_trackers
scheduler.join

