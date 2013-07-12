#
# Interface for all Dequeues (double-ended queues)
#
# Author: C. Fox
# Version: October 2011

require "Container"

class Dequeue < Container
  
  # Add an item to the front of the dequeue
  # @post: size = old.size+1
  #        if !old.empty? then rear == rear
  #        if old.empty? then front == rear == item 
  # @return: size
  def enter_front(e)
    raise NotImplementedError
  end

  # Add an item to the rear of a dequeue
  # @post: size = old.size+1
  #        if !old.empty? then front == front
  #        if old.empty? then front == rear == item 
  # @return: size
  def enter_rear(e)
    raise NotImplementedError
  end

  # Remove and return the front element
  # @pre: not empty?
  # @post: size == old.size-1
  #        old.rear == rear
  def leave_front()
    raise NotImplementedError
  end

  # Remove and return the rear element
  # @pre: not empty?
  # @post: size == old.size-1
  #        old.front == front
  def leave_rear()
    raise NotImplementedError
  end

  # Return, but do not remove, the front element
  # @pre: not empty?
  # @post: size == old.size
  def front()
    raise NotImplementedError
  end

  # Return, but do not remove, the rear element
  # @pre: not empty?
  # @post: size == old.size
  def rear()
    raise NotImplementedError
  end
  
end