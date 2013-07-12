#
# This is the root of the Container hierarchy. A Container simply holds things, so there are not
# many operations that it can have.
#
# Author: C. Fox
# Version: May 2011

class Container
  
  # @inv: empty? iff size == 0
  
  # Return the number of entities in the Container
  def size
    raise NotImplementedError
  end
  
  # Return true iff the container has no elements
  def empty?
    0 == size
  end
  
  # Make a container empty
  # @return: 0
  def clear
    raise NotImplementedError
  end
end