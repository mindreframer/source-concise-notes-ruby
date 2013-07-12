#
# Interface for all Stacks
#
# Author: C. Fox
# Version: July 2011

require "Container"

class Stack < Container
  
  # Add an item to the stack
  # @post: size = old.size+1 and top == item
  # @result: size
  def push(item)
    raise NotImplementedError
  end
  
  # Remove and return the top item on the stack
  # @pre: !empty?
  # @post: size = old.size-1
  def pop
    raise NotImplementedError
  end
  
  # Return the top item on the stack
  # @pre: !empty?
  # post: size = old.size   
  def top
    raise NotImplementedError
  end
end