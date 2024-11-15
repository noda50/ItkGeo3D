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

#$LOAD_PATH.addIfNeed("~/lib/ruby");
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
  def deg2rad(_deg)
    return _deg * Deg2Rad ;
  end

  #--------------------------------------------------------------
  #++
  ## convert radian to degree
  def rad2deg(_rad)
    return _rad * Rad2Deg ;
  end

  #--------------------------------------------------------------
  #++
  ## normalize _angle in radian between -PI and PI
  ## _ang_:: angle in radian.
  ## _onlyPositiveP_:: use range [0, 2PI]
  ## *return*:: normalized angle.
  def normalizeAngle(_ang, _onlyPositiveP = false)
    _ang = 0.0 if (_ang > HugeAngle || _ang < -HugeAngle) ;
    _ang += DoublePI while(_ang < -PI) ;
    _ang -= DoublePI while(_ang >  PI) ;

    _ang += DoublePI if(_onlyPositiveP && _ang < 0.0) ;
    
    return _ang ;
  end

  #--------------------------------------------------------------
  #++
  ## normalize angle in degree between -180 and 180
  ## _ang_:: angle in radian.
  ## _onlyPositiveP_:: use range [0, 360]
  ## *return*:: normalized angle.
  def normalizeAngleDeg(_ang, _onlyPositiveP = false)
    _ang = 0.0 if (_ang > HugeAngle || _ang < -HugeAngle) ;
    _ang += 360.0 while(_ang < -180.0) ;
    _ang -= 360.0 while(_ang >  180.0) ;

    _ang += 360.0 if(_onlyPositiveP && _ang < 0.0) ;

    return _ang ;
  end

  #--------------------------------------------------------------
  #++
  ## check angle is in order
  ## _from_:: smallest angle
  ## _mid_:: middle angle
  ## _to_:: largest angle
  ## _permitSameP_:: flag to return true in the case angles are the same.
  ## *return*:: true if angles align right order.
  def isAngleInOrder(_from, _mid, _to, _permitSameP = true)
    _fromTo = normalizeAngle(_to - _from, true) ;
    _fromMid = normalizeAngle(_mid - _from, true) ;

    if(_permitSameP) then
      return (_fromMid >= 0.0 && _fromTo >= _fromMid) ;
    else
      return (_fromMid > 0.0 && _fromTo > _fromMid) ;
    end
  end

  #--------------------------------------------------------------
  #++
  ## choose minimum value
  def min(*_values)
    return _values.min() ;
  end

  #--------------------------------------------------------------
  #++
  ## choose maximum value
  def max(*_values)
    return _values.max() ;
  end

  #--------------------------------------------------------------
  #++
  ## bound
  ## _value_:: a Numeric to be bounded.
  ## _min_:: minimum of the bounding range
  ## _max_:: maximum of the bounding range
  def bound(_value, _min, _max)
    return min(max(_value,_min),_max)
  end

  #--------------------------------------------------------------
  #++
  ## absolute value
  def abs(_value)
    return ((_value >= 0.0) ? _value : -_value) ;
  end

  #--------------------------------------------------------------
  #++
  ## float random value
  def fltRand(_min, _max)
    _w = _max - _min ;
    return min + _w * rand(0) ;
  end
    
  #--------------------------------------------------------------
  #++
  ## angle order check
  def isAnglesInOrder(_first, _second, _third)
    # suppose each angle is less than PI if angles are in order.
    _angleFirstSecond = normalizeAngle(_second - _first) ;
    _angleSecondThird = normalizeAngle(_third - _second) ;
    return _angleFirstSecond >= 0.0 && _angleSecondThird >= 0.0 ;
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
