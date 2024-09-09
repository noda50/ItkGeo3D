#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = GeoObject class
## Author:: Itsuki Noda
## Version:: 0.0 2024/09/07 I.Noda
##
## === History
## * [2024/09/07]: Create This File.
## * [YYYY/MM/DD]: add more
## == Usage
## * ...

def $LOAD_PATH.addIfNeed(path, lastP = false)
  existP = self.index{|item| File.identical?(File.expand_path(path),
                                             File.expand_path(item))} ;
  if(!existP) then
    if(lastP) then
      self.push(path) ;
    else
      self.unshift(path) ;
    end
  end
end

$LOAD_PATH.addIfNeed("~/lib/ruby");
$LOAD_PATH.addIfNeed(File.dirname(__FILE__));

require 'pp' ;
require 'WithConfParam.rb' ;

require 'Utility.rb' ;


module Itk ; module Geo3D
#--======================================================================
#++
## 
class GeoObject
  include Geo3D
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## description of attribute foo.
  attr :foo, true ;
  ## description of attribute baz.
  attr_accessor :baz ;
  ## description of attribute bar.
  attr_reader :bar ;

  #--------------------------------------------------------------
  #++
  ## description of method initialize
  ## _baz_:: about argument baz.
  def initialize(baz)
    @baz = baz ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## ensure a GeoObject (for class)
  ## _aValue_:: a certain format or class of GeoObject
  ## *return*:: a GeoObject
  def self.sureGeoObject(_aValue)
    raise ("sureGeoObject() should be defined in each class: class=" +
           self.inspect) ;
  end

  #------------------------------------------
  #++
  ## ensure a GeoObject (for instance)
  ## _aValue_:: a certain format or class of GeoObject
  ## *return*:: a GeoObject
  def sureGeoObject(_aValue)
    return self.class.sureGeoObject(_aValue) ;
  end

  #--------------------------------------------------------------
  #++
  ## description of method foo
  ## _bar_:: about argument bar
  ## *return*:: about return value
#  def foo(bar, &block) # :yield: arg1, arg2
#  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Foo
end ; end

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'

  #--============================================================
  #++
  # :nodoc:
  ## unit test for this file.
  class TC_Foo < Test::Unit::TestCase
    #--::::::::::::::::::::::::::::::::::::::::::::::::::
    #++
    ## desc. for TestData
    TestData = nil ;

    #----------------------------------------------------
    #++
    ## show separator and title of the test.
    def setup
#      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      name = "#{(@method_name||@__name__)}(#{self.class.name})" ;
      puts ('*' * 5) + ' ' + [:run, name].inspect + ' ' + ('*' * 5) ;
      super
    end

    #----------------------------------------------------
    #++
    ## about test_a
    def test_a
      pp [:test_a] ;
      assert_equal("foo-",:foo.to_s) ;
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
