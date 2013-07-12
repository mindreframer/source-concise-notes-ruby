#
# A Map holds key-value pairs acccessible through the key.
#
# Author: C. Fox
# Version: August 2011

require "Collection"

class Map < Collection
  
  # Return the value with the indicated key, or nil if none
  def [](key)
    raise NotImplementedError
  end
  
  # Add a key-value pair to the map; replace the value if a pair with the key is already present
  # @return: element
  def []=(key, value)
    raise NotImplementedError
  end
  
  # Remove the pair with the designated key from the map, or do nothing
  # @return: the value of the removed pair, or nil if the key is not present
  def delete(key)
    raise NotImplementedError
  end
  
  # Return true iff the key is present in the map
  def has_key?(key)
    raise NotImplementedError
  end
  
  # Return true iff the value is present in the map
  def has_value?(value)
    raise NotImplementedError
  end
  
end