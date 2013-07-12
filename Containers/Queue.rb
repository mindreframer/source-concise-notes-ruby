#
# Interface for all Queues
#
# Author: C. Fox
# Version: July 2011

require "Container"

class Queue < Container
  
  # Add an item to the back of the queue
  # @post: size = old.size+1
  #        if !old.empty? then front == old.front
  #        if old.empty? then front == item
  # @result: size
  def enter(item)
    raise NotImplementedError
  end
  
  # Remove and return the item at the front of the queue
  # @pre: !empty?
  # @post: size == old.size-1
  def leave
    raise NotImplementedError
  end
  
  # Return the front item in the queue, but don't remove it
  # @pre: !empty?
  # @post: size == old.size
  def front
    raise NotImplementedError
  end

end