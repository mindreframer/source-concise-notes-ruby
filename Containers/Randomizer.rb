#
# Interface for all Randomizers. A Randomizer is like a queue in that values
# enter and leave, but values leave in random order. Such a data type is useful
# when implementing a network node that makes traffic untraceable, for example.
#
# Author: C. Fox
# Version: July 2011

require "Container"

class Randomizer < Container
  
  # Add an item to the randomizer
  # @post: size = old.size + 1
  # @return: size
  def enter(item)
    raise NotImplementedError
  end

  # Remove and return an item from the randomizer
  # @pre: not empty?
  # @post: size == @old.size - 1
  def leave()
    raise NotImplementedError
  end
end