#
# This is the parent interface for all traversible containers. A Collection is an
# Enumerable entity, but has only one operation of its own (besides those it inherits
# from Container).
#
# Author: C. Fox
# Version: August 2011

require "Container"

class Collection < Container
  include Enumerable

  # Return an external iterator object for this Collection
  def iterator()
    raise NotImplementedError
  end

  # Return true iff an element is present in this collection
  def contains?(element)
    raise NotImplementedError
  end
  
  # Redefine == so concrete collections are forced to implement this operation
  # Return true iff this collection is the same as another
  def ==(other)
    raise NotImplementedError
  end
end