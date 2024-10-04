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

  #------------------------------------------
  #++
  ## insert Point to nth
  ## _point_:: a Point.
  ## _nth_:: insert point. 0..nofPoints
  def insertPointAt(_point, _nth)
    @pointList.insert(_nth, _point) ;
    @lineList = nil ;
    
    return @pointList ;
  end

  #------------------------------------------
  #++
  ## remove Point to nth
  ## _point_:: a Point.
  ## _nth_:: insert point. 0..nofPoints
  def removePointAt(_nth)
    _point = @pointList[_nth] ;
    @pointList.delete_at(_nth) ;
    @lineList = nil ;
    
    return _point ;
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
      return self.clone() ;
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
  ## number of Points
  ## *return*:: number of points
  def nofPoints()
    return self.pointList.length() ;
  end
  
  #------------------------------------------
  #++
  ## number of Points
  ## *return*:: number of points
  def nofLines()
    return self.lineList.length() ;
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
    sureLineList() ;
    _count = 0 ;
    @lineList.each{|_line|
      _block.call(_line, _count) ;
      _count += 1 ;
    }
  end

  #-----------------------------------------
  #++
  ## ensure @lineList
  def sureLineList()
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

    return @lineList ;
  end

  #-----------------------------------------
  #++
  ## nth Point
  def nthPoint(_nth)
    return @pointList[_nth] ;
  end

  #-----------------------------------------
  #++
  ## nth LineSegment
  def nthLine(_nth)
    sureLineList() ;
    return @lineList[_nth] ;
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
  # distance
  #--------------------------------------------------------------
  #++
  ## distance to Point
  ## _point_:: a Point
  ## *return*:: [_distance_, _footPoint_, _lineSegment_, _frac_]
  ##            _frac_:: 垂線の足の線分上の分率。
  def distanceInfoToPoint(_point)
    _minDist = nil ;
    _minInfo = nil ;
    self.eachLine{|_line|
      (_dist, _foot, _frac) = _line.distanceInfoFromPoint(_point, false) ;
      if(_minDist.nil? || _minDist > _dist) then
        _minDist = _dist ;
        _minInfo = [_dist, _foot, _line, _frac] ;
      end
    }
    return _minInfo ;
  end

  #------------------------------------------
  #++
  ## distance to LineSegment
  ## _lineOther_:: a LineSegment
  ## *return*:: [_distance_, _segment_, _lineSegment_, [_fracSelf,_fracOther_]]
  def distanceInfoToLine(_lineOther)
    _minDist = nil ;
    _minInfo = nil ;
    self.eachLine{|_lineSelf|
      (_dist, _segment, _fracPair) =
        _lineSelf.distanceInfoToLine(_lineOther, false) ;
      if(_minDist.nil? || _minDist > _dist) then
        _minDist = _dist ;
        _minInfo = [_dist, _segment, _lineSelf, _fracPair] ;
      end
    }
    return _minInfo ;
  end

  #----------------------
  #++
  ## distance to LineSegment
  ## _lineOther_:: a LineSegment
  ## *return*:: [_distance_, _segment_, _lineSegment_, [_fracSelf,_fracOther_]]
  alias distanceInfoToLineSegment distanceInfoToLine ; 

  #------------------------------------------
  #++
  ## distance to LineString
  ## _stringOther_:: a LineString
  ## *return*:: [_distance_, _segment_, _linePair_, _fracPair_]
  ##            _linePair_::= [_lineSelf, _lineOther]
  ##            _fracPair_::= [_fracSelf, _fracOther]
  def distanceInfoToLineString(_stringOther)
    _minDist = nil ;
    _minInfo = nil ;
    _stringOther.eachLine{|_lineOther|
      (_dist, _segment, _lineSelf, _fracPair) =
        self.distanceInfoToLine(_lineOther) ;
      if(_minDist.nil? || _minDist > _dist) then
        _minDist = _dist ;
        _minInfo = [_dist, _segment, [_lineSelf, _lineOther], _fracPair] ;
      end
    }
    return _minInfo ;
  end

  #----------------------
  #++
  ## distance to LineString
  ## _stringOther_:: a LineString
  ## *return*:: _distance_
  def distanceToLineString(_stringOther)
    return distanceInfoToLineString(_stringOther).first ;
  end
  
  #--////////////////////////////////////////////////////////////
  # create shape
  #--============================================================
  #--------------------------------------------------------------
  #++
  ## create ellipse
  ## _center_:: center Point.
  ## _axisA_:: first axis Vector.
  ## _axisB_:: second axis Vector.
  ## _nofSeg_:: number of segmentation.
  ## _closeP_:: flag of close or not.
  ## _fromAngle_:: start angle.
  ## _toAngle_:: end angle.
  def self.newEllipticPath(_center, _axisA, _axisB,
                           _nofSeg = 16, _closeP = false,
                           _fromAngle = 0.0, _toAngle = 2 * PI)
    _center = PointClass.sureGeoObject(_center) ;
    _axisA = VectorClass.sureGeoObject(_axisA) ;
    _axisB = VectorClass.sureGeoObject(_axisB) ;
    _dAngle = (_toAngle - _fromAngle)/_nofSeg.to_f ;

    _pointList = [] ;
    (0..._nofSeg).each{|_k|
      _angle = _fromAngle + _k * _dAngle ;
      _point = _center + _axisA.ellipticMixtureWith(_axisB, _angle) ;
      _pointList.push(_point) ;
    }

    return self.new(_pointList, _closeP) ;
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
    ## create and draw
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

    #----------------------------------------------------
    #++
    ## distance
    def test_b
      n = 12 ;
      c0 = LineString.newEllipticPath([2,2,0], [1,0,0], [0,1,0], n, true) ;
      c1 = LineString.newEllipticPath([1.5,1,0], [1,1,1], [0,0,1], n, false) ;

      (dist, seg, linePair, fracPair) = c0.distanceInfoToLineString(c1) ;

      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z"} ;
      Gnuplot::directMulti3dPlot([:c0, :c1, :seg, :l0, :l1], gconf){|gplot|
        c0.draw(gplot, :c0) ;
        c1.draw(gplot, :c1) ;
        seg.draw(gplot, :seg) ;
        linePair[0].draw(gplot, :l0) ;
        linePair[1].draw(gplot, :l1) ;
      }
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
