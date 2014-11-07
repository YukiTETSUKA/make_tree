#! /usr/bin/ruby

require 'rubygems'
require 'decisiontree'
require 'json'
require 'pp'

$attributes = ['gender', 'hometown', 'location']
$training = []
proc = Proc.new {false}

profiles = open('./assets/profiles.json') do |io|
  JSON.load(io)['profiles']
end

checkins = open('./assets/checkins_data.json') do |io|
  JSON.load(io)[ARGV[0]]
end

profiles.each_with_index do |value, i|
  # get_attr '', value
  raw_attributes = value['facebook_user']['raw_attributes']
  user_id = raw_attributes['id']
  have_been = checkins['user_ids'].find(proc){|item| item == user_id}
  $training[i] = []
  $training[i].push raw_attributes['gender']
  $training[i].push raw_attributes['hometown']['name']
  $training[i].push raw_attributes['location']['name']
  $training[i].push (have_been === false ? false: true)
end

dec_tree = DecisionTree::ID3Tree.new($attributes, $training, true, gender: :discrete, hometown: :discrete, location: :discrete)
dec_tree.train

# test = [37, 'sick']

# decision = dec_tree.predict(test)
# puts "Predicted: #{decision} ... True decision: #{test.last}"
puts ["\n", checkins['name'], dec_tree.build_rules, $training.classification.entropy]

# Graph the tree, save to 'tree.png'
dec_tree.graph(ARGV[0])
