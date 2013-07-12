#
# A Set holds entities without any order. An element can appear only once.
#
# Author: C. Fox
# Version: August 2011

require "Collection"

class Set < Collection
  
  # Return true iff every member of set is a member of self
  def subset?(set)
    raise NotImplementedError
  end
  
  # Put element into this set; replace it if it is already there
  # @return: element
  def insert(element)
    raise NotImplementedError
  end
  
  # Take an element out of this set
  # @return: the removed element
  def delete(element)
    raise NotImplementedError
  end
  
  # Return the intersection of this set with set
  def &(set)
    raise NotImplementedError
  end
  
  # Return the union of this set with set
  def +(set)
    raise NotImplementedError
  end
  
  # Return the relative complement of this set with set
  def -(set)
    raise NotImplementedError
  end
  
end