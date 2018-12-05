# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


require 'csv'
require 'open-uri'
records = CSV.table(open('https://exports.tachibana.cool/imas/ml/td/tb.csv'))
max = Score.maximum(:datetime)
records = records.select { |r| Time.parse(r[:datetime]) > max } if max
records.each do |r|
  Score.create(r.to_h)
end
