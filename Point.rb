#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Geo3D Point class
## Author:: Itsuki Noda
## Version:: 0.0 2024/09/09 I.Noda
##
## === History
## * [2024/09/09]: Create This File.
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

require 'Vector.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## Itk::Geo3D::Point class
class Point < Vector
  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Point
  ## _aValue_:: a Point, Vector or [_x_, _y_]
  ## *return* :: a Vector
  def self.sureGeoObject(_aValue)
    case _aValue ;
    when Point ;
      return _aValue ;
    when Vector ;
      return Point.new(_aValue) ;
    when Array ;
      return Point.new(_aValue) ;
    else
      raise ("#{self}::sureGeoObject() does not support conversion from : " +
             _aValue.inspect) ;
    end
  end

  #------------------------------------------
  #++
  ## ensure a Point
  ## _aValue_:: a Vector or [_x_, _y_]
  ## *return* :: a Vector
  def surePoint(_aValue) ;
    return sureGeoObject(_aValue) ;
  end


  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Point
#--======================================================================
end ; end # module Geo3D ; module Itk

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'

  include Itk::Geo3D ;

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
    ## sureGeoObject
    def test_a
      v = Point.new() ;
      [Point.new(0,1,2), Vector.new(1,2,3), [4,5,6], 7, nil].each{|aValue|
        begin
          p [:sureGeoObject, aValue, Point.sureGeoObject(aValue)] ;
          p [:sureVector, aValue, v.sureVector(aValue)] ;
          p [:surePoint, aValue, v.surePoint(aValue)] ;
        rescue => ex
          pp [:rescue, ex.to_s, ex.backtrace[0...5]] ;
        end
      }
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
