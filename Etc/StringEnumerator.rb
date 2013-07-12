#
# StringIterator is an external iterator for strings with a backup
# facility and clean checks for the end of the iteration. Reading past
# the end of the string returns nil rather than raising an exception.
#
# Christopher Fox
# October 2011
#
class StringEnumerator
  
  # Set attributes
  # @pre: argument must be a String
  def initialize(string)
    raise ArgumentError unless string.class == String
    @string = string
    @index = 0
  end
  
  # Advance to the next item, returning it as well
  # @result: the next element in the string, or nil if empty?
  def next()
    @index += 1
    @string[@index...(@index+1)]
  end
  
  # Return the current value of the iterator, or nil if empty?
  def current()
    @string[@index...(@index+1)]
  end
  
  # Backup in the iteration, one spot by default
  # @pre: can't back up past the start of the string
  def back_up(n = 1)
    raise ArgumentError if @index < n
    @index -= n
  end
  
  # True iff the iteration is over
  def empty?()
    @string.length <= @index
  end
end
