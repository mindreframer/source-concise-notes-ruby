#
# Interface for all Collection external Iterators
#
# Author: C. Fox
# Version: July 2011

class Iterator
  
  # Prepare for an iteration
  # @post: current == first item in Collection if !empty?
  def rewind
    raise NotImplementedError
  end
  
  # See whether iteration is complete
  def empty?
    raise NotImplementedError
  end
  
  # Obtain the current element
  # @result: current element or nil if empty?
  def current
    raise NotImplementedError
  end

  # Move to the next element
  # @result: next element or nil if empty?
  def next
    raise NotImplemetedError
  end
end