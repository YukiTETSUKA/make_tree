#! /usr/bin/ruby

require 'json'
require 'pp'

$checkins = {}
proc = Proc.new {false}

checkins = open './assets/checkins.json' do |io|
  JSON.load(io)['checkins']
end

checkins.each_with_index do |value, i|
  place_id = value['fb_location']['place']['id']
  if not $checkins[place_id].is_a? ::Hash
    $checkins[place_id] = {}
    $checkins[place_id][:name] = value['fb_location']['place']['name']
    $checkins[place_id][:user_ids] = [value['fb_location']['from']['id']]
  end
  if $checkins[place_id][:user_ids].find(proc){|item| item == value['fb_location']['from']['id']} === false
    $checkins[place_id][:user_ids].push value['fb_location']['from']['id']
  end
end

if not File.exist? './assets/checkins_data.json'
  open './assets/checkins_data.json', "w" do |f|
    f.write $checkins.to_json
  end
end

$checkins.each do |key, value|
  sleep(1)
  if key.is_a? ::String
    system "ruby make_tree.rb #{key}"
  end
end
