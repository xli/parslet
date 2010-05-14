require File.dirname(__FILE__) + '/../spec_helper'

require 'parslet'

describe "Regressions from real examples" do
  # This parser piece produces on the left a subtree that is keyed (a hash)
  # and on the right a subtree that is a repetition of such subtrees. I've
  # for now decided that these would merge into the repetition such that the
  # return value is an array. This avoids maybe loosing keys/values in a 
  # hash merge. 
  #
  class ArgumentListParser
    include Parslet
    def argument_list
      expression.as(:argument) >> 
        (comma >> expression.as(:argument)).repeat
    end
    def expression
      named('expression') {
        (
          string
        )
      }
    end
    def string
      named('string') {
        str('"') >> 
        (
          (str('\\') >> any) /
          (str('"').absnt? >> any)
        ).repeat.as(:string) >>
        str('"') >> space?
      }
    end
    def comma
      str(',') >> space?
    end
    def space?
      named('whitespace') { space.maybe }
    end
    def space
      match("[ \t]").repeat(1)
    end
    
    def parse(str)
      argument_list.parse(str)
    end
  end
  context ArgumentListParser do
    it 'should parse "arg1", "arg2"' do
      result = ArgumentListParser.new.parse('"arg1", "arg2"')
      
      result.should have(2).elements
      result.each do |r|
        r[:argument]
      end
    end
    it 'should parse "arg1", "arg2", "arg3"' do
      result = ArgumentListParser.new.parse('"arg1", "arg2", "arg3"')
      
      result.should have(3).elements
      result.each do |r|
        r[:argument]
      end
    end
  end

end