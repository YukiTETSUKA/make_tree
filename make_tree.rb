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

if $training.classification.entropy > 0.0
  result = "success"
  rules = dec_tree.build_rules
else
  result = "error"
  rules  = []
end

output = {
  :result  => result,
  :id      => ARGV[0],
  :name    => checkins['name'],
  :rules   => rules,
  :entropy => $training.classification.entropy
}

open "./result/json/#{ARGV[0]}.json", "w" do |f|
  f.write output.to_json
end

# Graph the tree, save to 'tree.png'
dec_tree.graph("./result/img/#{ARGV[0]}")

test = ['male', 'Utsunomiya, Tochigi, Japan', 'Utsunomiya, Tochigi, Japan']

decision = dec_tree.predict(test)
puts "Predicted: #{decision} ... True decision: #{test.last}"
