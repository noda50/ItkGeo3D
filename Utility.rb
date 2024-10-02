#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Geo3D Utility
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

module Itk
#--======================================================================
#++
## Geo3D module
module Geo3D
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## PI
  PI = Math::PI ;
  ## 2 PI
  DoublePI = 2.0 * PI ;
  ## PI/2
  HalfPI = PI / 2.0 ;
  
  ## convertion constants from degree to radian
  Deg2Rad = PI / 180.0 ;
  ## convertion constants from radian to degree
  Rad2Deg = 180.0 / PI ;

  ## huge number used in normalizeAngle
  HugeAngle = 1.0e5 ;
  
  ## EPS
  EPS = 1.0e-10 ;

  #--------------------------------------------------------------
  #++
  ## almost zero.
  def isAlmostZero(_value, _eps = EPS)
    return (_value < _eps && _value > -_eps) ;
  end
  
  #--------------------------------------------------------------
  #++
  ## convert degree to radian
  def deg2rad(deg)
    return deg * Deg2Rad ;
  end

  #--------------------------------------------------------------
  #++
  ## convert radian to degree
  def rad2deg(rad)
    return rad * Rad2Deg ;
  end

  #--------------------------------------------------------------
  #++
  ## normalize angle in radian between -PI and PI
  def normalizeAngle(ang)
    ang = 0.0 if (ang > HugeAngle || ang < -HugeAngle) ;
    ang += DoublePI while(ang < -PI) ;
    ang -= DoublePI while(ang >  PI) ;
    return ang ;
  end

  #--------------------------------------------------------------
  #++
  ## normalize angle in degree between -180 and 180
  def normalizeAngleDeg(ang)
    ang += 360.0 while(ang < -180.0) ;
    ang -= 360.0 while(ang >  180.0) ;
    return ang ;
  end

  #--------------------------------------------------------------
  #++
  ## choose minimum value
  def min(*value)
    return value.min() ;
  end

  #--------------------------------------------------------------
  #++
  ## choose maximum value
  def max(*value)
    return value.max() ;
  end

  #--------------------------------------------------------------
  #++
  ## absolute value
  def abs(value)
    return ((value >= 0.0) ? value : -value) ;
  end

  #--------------------------------------------------------------
  #++
  ## float random value
  def fltRand(min, max)
    w = max - min ;
    return min + w * rand(0) ;
  end
    
  #--------------------------------------------------------------
  #++
  ## angle order check
  def isAnglesInOrder(first, second, third)
    # suppose each angle is less than PI if angles are in order.
    angleFirstSecond = normalizeAngle(second - first) ;
    angleSecondThird = normalizeAngle(third - second) ;
    return angleFirstSecond >= 0.0 && angleSecondThird >= 0.0 ;
  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # module Geo3D
end # module Itk

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
