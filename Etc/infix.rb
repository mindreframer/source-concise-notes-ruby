#
# CS 240 PA2: Evaluate simple infix expressions using recursion and stacks
#
# Chistopher Fox
# October 2011

# Tell the interpreter where to look for these: ruby -I<Containers directory> -I<StringEnumerator directory>
# Or append the directory name to $: here
# In Eclipse, set the run parameters for the interpreter as above
require "LinkedStack"
require "StringEnumerator"

# Helper to evaluate an expression given an operator (string) and two arguments (integers)
def evaluate(op, left_arg, right_arg)
  case
  when op == '+' then return left_arg + right_arg
  when op == '-' then return left_arg - right_arg
  when op == '*' then return left_arg * right_arg
  when op == '/' then return left_arg / right_arg
  when op == '%' then return left_arg % right_arg
  end
end

INVALID_CHARACTERS = /[^\d+\-*\/%()]/
OPERATORS = /[+\-*\/%]/

################# Recursive Infix Evaluation ####################

# Evaluate a simple infix arithmetic expression using recursion
# @pre: only digits and operators appear in string
def recursive_eval_infix(string)
  raise "Bad characters" if string =~ INVALID_CHARACTERS
  source = StringEnumerator.new(string)
  result = eval_infix(source)
  raise "Extra characters at the end of the expression" unless source.empty?
  result
end

# Recursive helper function to evaluate a simple infix expression
def eval_infix(source)
  ch = source.current
  source.next
  if ch == '('
    left_arg = eval_infix(source)
    raise "Missing right parenthesis" unless source.current == ')'
    source.next
  elsif ch =~ /\d/
    left_arg = ch.to_i
  else
    raise "Missing argument"
  end
  while source.current =~ OPERATORS
    op = source.current
    ch = source.next
    if ch == '('
      source.next
      right_arg = eval_infix(source)
      raise "Missing right parenthesis" unless source.current == ')'
    elsif ch =~ /\d/
      right_arg = ch.to_i
    else
      raise "Missing argument"
    end
    left_arg = evaluate(op, left_arg, right_arg)
    source.next
  end
  left_arg
end

################ Stack-Based Infix Evaluation ################

# Evaluate a simple infix arithmetic expression using a stack
# @pre: only digits and oeprators appear in string
def stack_eval_infix(string)
  raise "Bad characters" if string =~ INVALID_CHARACTERS
  op_stack = LinkedStack.new
  value_stack = LinkedStack.new
  string.chars do | ch |
    case
    when ch =~ /\d/ || ch == ')'
      if ch == ')'
        raise "Missing left parenthesis" if op_stack.empty? || op_stack.top != '('
        op_stack.pop
      else
        value_stack.push(ch.to_i)
      end
      while !op_stack.empty? && op_stack.top =~ OPERATORS
        op = op_stack.pop
        raise "Missing argument" if value_stack.empty?
        right_arg = value_stack.pop
        raise "Missing argument" if value_stack.empty?
        left_arg = value_stack.pop
        value_stack.push( evaluate(op, left_arg, right_arg) )
      end
    when ch =~ OPERATORS || ch == '('
      op_stack.push(ch)
    end
  end
  raise "Missing expression" if value_stack.empty?
  raise "Too many arguments" unless value_stack.size == 1
  raise "Missing argument" unless op_stack.empty?
  value_stack.pop
end

################### main script ##################
puts "Infix expression evaluator."
begin
  print "> "
  string = gets.gsub(/\s/,"")
  next if string.empty?
  begin
    puts recursive_eval_infix(string)
  rescue Exception => e
    puts e.to_s
  end
  begin
    puts stack_eval_infix(string)
  rescue Exception => e
    puts e
  end
end until string.empty?
puts "Bye."
