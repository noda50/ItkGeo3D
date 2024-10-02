#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = LineString class
## Author:: Itsuki Noda
## Version:: 0.0 2024/10/02 I.Noda
##
## === History
## * [2024/10/02]: Create This File.
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

require 'LineSegment.rb' ;

module Itk ; module Geo3D ;
#--======================================================================
#++
## Line String class
class LineString < GeoObject
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## Default Point class
  PointClass = Point ;
  ## Default Vector class
  VectorClass = Vector ;
  ## Default LineSegment class
  LineSegmentClass = LineSegment ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## Array of Point
  attr :pointList, true ;
  ## Array of LineSegment (generated if needed)
  attr :lineList, true ;

  #--------------------------------------------------------------
  #++
  ## initialize.
  ## _pointList_:: Array of Point.
  ## _closeP_:: if true, force to close LineString.
  ## _dupP_:: if false, use _pointList.
  def initialize(_pointList, _closeP = false) ;
    set(_pointList, _closeP) ;
  end

  #------------------------------------------
  #++
  ## set
  ## _pointList_:: Array of Point.
  ## _closeP_:: if true, force to close LineString.
  def set(_pointList,_closeP = false)
    @pointList = [] ;
    _pointList.each{|_point|
      @pointList.push(PointClass.sureGeoObject(_point)) ;
    }
    @pointList.push(@pointList.first) if(_closeP) ;
    
    @lineList = nil ;

    return self ;
  end

  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Point
  ## _aValue_:: a Point, Vector or [_x_, _y_]
  ## *return* :: a Point
  def self.sureGeoObject(_aValue)
    case _aValue ;
    when self ;
      return _aValue ;
    when Array ;
      return self.new(_aValue) ;
    else
      raise ("#{self}::sureGeoObject() does not support conversion from : " +
             _aValue.inspect) ;
    end
  end

  #--::::::::::::::::::::::::::::::::::::::::
  #------------------------------------------
  #++
  ## ensure a Point. (for class)
  ## _aValue_:: a Point, Vector or [_x_, _y_]
  ## *return* :: a Point
  def self.sureLineString(_aValue) ;
    return self.sureGeoObject(_aValue) ;
  end
  
  #------------------------------------------
  #++
  ## ensure a Point
  ## _aValue_:: a Point, Vector or [_x_, _y_]
  ## *return* :: a Point
  def sureLineString(_aValue) ;
    return sureGeoObject(_aValue) ;
  end

  #------------------------------------------
  #++
  ## duplicate
  ## _deepP_:: flag to deep duplicate.
  def dup(_deepP = true)
    if(_deepP)
      _pointList = [] ;
      self.eachPoint{|_point|
        _pointList.push(_point.dup(_deepP)) ;
      }
      return self.class.new(_pointList) ;
    else
      return self.dup() ;
    end
  end

  #------------------------------------------
  #++
  ## reverse
  ## _dupP_:: flag to duplicate
  def reverse(_dupP = false)
    _pointList = [] ;
    self.eachPoint{|_point|
      _pointList.push((_dupP ? _point.dup : _point)) ;
    }
    
    return self.class.new(_pointList) ;
  end

  #------------------------------------------
  #++
  ## length
  ## *return*:: a total length of LineString.
  def length()
    _length = 0 ;
    self.eachLine{|_line|
      _length += _line.length() ;
    }
    return _length ;
  end

  #------------------------------------------
  #++
  ## check closed
  ## *return*:: true if the LineString is closed.
  def isClosed(_eps = EPS) ;
    return true if(@pointList.first == @pointList.last) ;
    return true if(@pointList.first.distanceToPoint(@pointList.last) < _eps) ;
    return false ;
  end

  #--////////////////////////////////////////////////////////////
  # each
  #--------------------------------------------------------------
  #++
  ## each point loop
  def eachPoint(&_block) # :yield: _point_, _count_
    _count = 0 ;
    @pointList.each{|_point|
      _block.call(_point, _count) ;
      _count += 1 ;
    }
  end
  
  #-----------------------------------------
  #++
  ## each LineSegment loop
  def eachLine(&_block) # :yield: _line_, _count_
    if(@lineList.nil?) then
      @lineList = [] ;
      _prePoint = nil ;
      self.eachPoint{|_point|
        if(_prePoint) then
          _line = LineSegmentClass.new(_prePoint, _point) 
          @lineList.push(_line) ;
        end
        _prePoint = _point ;
      }
    end
    
    _count = 0 ;
    @lineList.each{|_line|
      _block.call(_line, _count) ;
      _count += 1 ;
    }
  end
  
  #--////////////////////////////////////////////////////////////
  # bbox and min/max XYZ
  #--------------------------------------------------------------
  #++
  ## minX
  def minX()
    _min = nil ;
    self.eachPoint{|_point|
      _min = _point.x if(_min.nil?) ;
      _min = min(_min, _point.x) ;
    }
    return _min ;
  end

  #------------------------------------------
  #++
  ## maxX
  def maxX()
    _max = nil ;
    self.eachPoint{|_point|
      _max = _point.x if(_max.nil?) ;
      _max = max(_max, _point.x) ;
    }
    return _max ;
  end

  #--------------------------------------------------------------
  #++
  ## minY
  def minY()
    _min = nil ;
    self.eachPoint{|_point|
      _min = _point.y if(_min.nil?) ;
      _min = min(_min, _point.y) ;
    }
    return _min ;
  end

  #------------------------------------------
  #++
  ## maxY
  def maxY()
    _max = nil ;
    self.eachPoint{|_point|
      _max = _point.y if(_max.nil?) ;
      _max = max(_max, _point.y) ;
    }
    return _max ;
  end

  #--------------------------------------------------------------
  #++
  ## minZ
  def minZ()
    _min = nil ;
    self.eachPoint{|_point|
      _min = _point.z if(_min.nil?) ;
      _min = min(_min, _point.z) ;
    }
    return _min ;
  end

  #------------------------------------------
  #++
  ## maxZ
  def maxZ()
    _max = nil ;
    self.eachPoint{|_point|
      _max = _point.z if(_max.nil?) ;
      _max = max(_max, _point.z) ;
    }
    return _max ;
  end
  

  #--////////////////////////////////////////////////////////////
  # convert
  #--------------------------------------------------------------
  #++
  ## to array
  def to_a()
    _pointList = [] ;
    self.eachPoint{|_point|
      _pointList.push(_point.to_a) ;
    }
    return _pointList ;
  end

  #------------------------------------------
  #++
  ## to Hash
  def to_h()
    return { pointList: self.to_a() } ;
  end

  #------------------------------------------
  #++
  ## to json
  def toJson()
    _json = { class: self.class.to_s } ;
    _json.update(to_h()) ;
    return _json ;
  end

  #--////////////////////////////////////////////////////////////
  # draw
  #--------------------------------------------------------------
  #++ 
  ## draw by gnuplot
  ## _gplot_:: a Gnuplot object.
  ## _drawId_:: key in multi-plot.
  def draw(_gplot, _drawId = self.drawId())
    _line = to_a() ;
    _gplot.dm3pPlotLine(_drawId, _line) ;
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class LineString
#--======================================================================
end ; end # module Geo3D ; module Itk

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'
  require 'gnuplot.rb' ;

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
    ## about test_a
    def test_a
      l0 = LineString.new([[0,0,0],[1,0,0],[1,1,0],[1,1,1],[0,1,1],[0,0,1]],
                          true) ;
      l1 = LineString.new([[0,1,0],[1,0,1],[0,-1,0]],false) ;
      p [:l0, l0.to_a, l0.length] ;
      p [:l1, l1.to_a, l1.length] ;

      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z"} ;
      Gnuplot::directMulti3dPlot([:l0, :l1, :l2, :d01, :d02], gconf){|gplot|
        l0.draw(gplot, :l0) ;
        l1.draw(gplot, :l1) ;
      }
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
