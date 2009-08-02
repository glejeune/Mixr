$:.unshift( "../lib" )
require 'mixr_client'

host = ARGV[0] || "localhost"

m = MixrClient.new( host, 9900 )

puts "---------------------------- set "
puts "set hello"
m["hello"] = "World"
puts "set coucou"
m["coucou"] = "le monde"
puts "set bonjour"
m["bonjour"] = "les gens"

puts "---------------------------- size "
puts "size : #{m.size}"

puts "---------------------------- index via mm"
puts m.index( "le monde" )

puts "---------------------------- get "
puts "get hello"
puts m["hello"]

puts "---------------------------- each_key "
m.each_key do |k|
  puts "Key : #{k}"
end

puts "---------------------------- each_value "
m.each_value do |k|
  puts "Value : #{k}"
end

puts "---------------------------- has_key? "
puts "Clé hello presente" if m.has_key?("hello")
puts "Clé zorglub abscente" unless m.has_key?("zorglub")

puts "---------------------------- has_value? "
puts "valeur les gens presente" if m.has_value?("les gens")
puts "valeur zorglub abscente" unless m.has_value?("zorglub")

puts "---------------------------- each "
puts "get each"
m.each do |k, v|
  puts "#{k} = #{v}"
end

puts "---------------------------- empty? "
puts "mixr vide" if m.empty?

puts "---------------------------- delete "
puts "delete key coucou"
puts "  value was #{m.delete("coucou")}"
puts "delete key coucou AGAIN !"
if m.delete("coucou").nil?
  puts "  value was nil"
end
puts m.delete( "coucou" ) {|el| "#{el} not found" }

puts "---------------------------- fetch "
puts m.fetch("bonjour")
puts m.fetch("cette cle n'existe pas", "donc cette valeur")
puts m.fetch("hello") { |e| "#{e} a ete supprime"}
puts m.fetch("coucou") { |e| "#{e} a ete supprime"}

puts "---------------------------- length "
puts "size : #{m.length}"

puts "---------------------------- clear "
m.clear
puts m["hello"]
puts "mixr vide" if m.empty?