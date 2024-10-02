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
require 'Itk/ItkPp.rb' ;

require 'Utility.rb' ;


module Itk ; module Geo3D
#--======================================================================
#++
## 
class GeoObject
  include Geo3D
  include ItkPp
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## description of attribute foo.
#  attr :foo, true ;

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

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## distance to other point.
  ## _toGeoObj_:: to GeoObject
  def distanceTo(_toGeoObj)
    case(_toGeoObj)
    when Point ;
      return distanceToPoint(_toGeoObj) ;
    else
      raise ("#{self.class}#distanceTo() does not support for _toGeoObj:" +
             _toGeoObj) ;
    end
  end
  
  #------------------------------------------
  #++
  ## distance from other point.
  ## _fromGeoObj_:: from GeoObject
  def distanceFrom(_fromGeoObj)
    return distanceTo(_fromGeoObj) ;
  end

  #------------------------------------------
  #++
  ## distance from other point.
  ## _fromGeoObj_:: from GeoObject
  def distanceToPoint(_fromGeoObj)
    raise ("#{self.class}#distanceToPoint() does not support for _toGeoObj:" +
           _toGeoObj) ;
  end

  #------------------------------------------
  #++
  ## distance from LineSegment
  ## _fromGeoObj_:: from LineSegment
  def distanceToLineSegment(_fromGeoObj)
    return _fromGeoObj.distanceTo(self) ;
  end

  #--////////////////////////////////////////////////////////////
  # bbox and min/max XYZ
  #--------------------------------------------------------------
  #++
  ## minX
  def minX()
    raise "minX() has not been defined in class : #{self.class().to_s}"
  end

  #------------------------------------------
  #++
  ## maxX
  def maxX()
    raise "maxX() has not been defined in class : #{self.class().to_s}"
  end

  #--------------------------------------------------------------
  #++
  ## minY
  def minY()
    raise "minY() has not been defined in class : #{self.class().to_s}"
  end

  #------------------------------------------
  #++
  ## maxY
  def maxY()
    raise "maxY() has not been defined in class : #{self.class().to_s}"
  end

  #--------------------------------------------------------------
  #++
  ## minZ
  def minZ()
    raise "minZ() has not been defined in class : #{self.class().to_s}"
  end

  #------------------------------------------
  #++
  ## maxZ
  def maxZ()
    raise "maxZ() has not been defined in class : #{self.class().to_s}"
  end
  
  #--////////////////////////////////////////////////////////////
  # Draw
  #--------------------------------------------------------------
  #++ 
  ## draw by gnuplot
  ## _gplot_:: a Gnuplot object.
  ## _drawId_:: key in multi-plot.
  def draw(_gplot, _drawId = self.drawId())
    raise "draw() has not been defined in class : #{self.class().to_s}" 
  end
  
  #--------------------------------------------------------------
  #++
  ## plot ID for the object
  def drawId()
    @_drawId = ppObjectName(true) if(@_drawId.nil?) ;
    return @_drawId ;
  end
  
  #--////////////////////////////////////////////////////////////
  # conversion
  #--------------------------------------------------------------
  #++
  ## convert to JSON Hash
  ## *return* :: a JSON in Hash.
  def toJson()
    _json = { class: self.class.to_s } ;
    _json.update(self.to_h) ;
  end

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class GeoObject
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
