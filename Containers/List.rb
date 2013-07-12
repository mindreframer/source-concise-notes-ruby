#
# This is the interface for all Lists
#
# Author: C. Fox
# Version: July 2011

require_relative "Collection"

class List < Collection
  
  # Insert the indicated element at the indicated location
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size+1 : index-old.size+1 
  # @result: self
  def insert(index, element)
    raise NotImplementedError
  end
  
  # Remove the element at index from the list
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size-1 : old.size
  # @result: the deleted element or nil if no element is deleted
  def delete_at(index)
    raise NotImplemetedError
  end
  
  # Fetch the element at the given index
  # @post: size == old.size
  # @result: (-old.size <= index < old.size) ? element at index : nil
  def [](index)
    raise NotImplementedError
  end
  
  # Replace a value in the list
  # @pre: -size <= index
  # @post: size = (-old.size <= index < old.size) ? old.size+1 : index-old.size+1 
  # @result: element
  def []=(index, element)
    raise NotImplementedError
  end
  
  # Find the index of an element in a list
  # @result: (element == self[index]) ? index : nil
  def index(element)
    raise NotImplementedError
  end
  
  # Return a sub-list of the list
  # @pre: -size <= index and 0 <= length
  # @result: the portion of the list starting at index and extending for length,
  #          but not past the end of the list
  def slice(index, length)
    raise NotImplementedError
  end

end