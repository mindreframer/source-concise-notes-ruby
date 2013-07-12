module Etc

  def hash_function(string, table_size)
     result = 0
     string.each_byte do |byte| 
       result = (result * 151 + byte) % table_size
     end
     return result
  end

  def Etc.A
    return 5
  end
end

#puts Etc.hash_function("fe, fi, fo fum", 98388) won't work because modules have no instances

include Etc
p hash_function("fe, fi, fo fum", 98388)

class IncludeEtc
  include Etc
  
  def self.B
    return 10
  end
end

c = IncludeEtc.new
puts IncludeEtc.B
puts Etc.A
puts c.hash_function("abc def", 8431)

# puts IncludeEtc.A won't work because non-instance methods are not included in classes

class << c
  def ha
    return 21
  end
end
puts c.ha