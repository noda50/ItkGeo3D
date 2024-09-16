#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Itk::Geo3D::LineSegment class
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

require 'Point.rb' ;



module Itk ; module Geo3D ;
#--======================================================================
#++
## Line Segment class
class LineSegment < GeoObject
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## Default Point class
  PointClass = Point ;
  ## Default Vector class
  VectorClass = Vector ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## start point
  attr :u, true ;
  ## end point
  attr :v, true ;

  #--------------------------------------------------------------
  #++
  ## inisialization.
  ## _u_:: start point
  ## _v_:: end point
  ## _dupP_:: flag to duplicate _U_ and _v_.
  def initialize(_u = self.class::PointClass::new(), 
                 _v = self.class::PointClass::new(),
                 _dupP = false)
    set(_u,_v,_dupP) ;
  end

  #------------------------------------------
  #++
  ## set
  ## _u_:: start point
  ## _v_:: end point
  ## _dupP_:: flag to duplicate _U_ and _v_.
  def set(_u,_v,_dupP = false)
    _u = PointClass::sureGeoObject(_u) ;
    _v = PointClass::sureGeoObject(_v) ;
    @u = (_dupP ? _u.dup() : _u) ;
    @v = (_dupP ? _v.dup() : _v) ;

    return self ;
  end

  #------------------------------------------
  #++
  ## duplicate
  ## _deepP_:: flag to deep duplicate.
  def dup(_deepP = true)
    _lSeg = clone() ; 
    if(_deepP)
        _lSeg.u = self.u.dup() ;
        _lSeg.v = self.v.dup() ;
    end
    return _lSeg ;
  end

  #------------------------------------------
  #++
  ## reverse
  ## _dupP_:: flag to duplicate
  def reverse(dupP = false)
    return self.class.new(self.v, self.u, dupP) ;
  end

  #------------------------------------------
  #++
  ## shift
  ## _drift_:: amount of drift. a Vector.
  ## *return*:: a shifted Vector.
  def length()
    return @u.distanceTo(@v)
  end

  #------------------------------------------
  #++
  ## difference Vector
  ## *return*:: a difference Vector.
  def diffVector()
    return @v - @u ;
  end

  #--////////////////////////////////////////////////////////////
  # 推薦
  #--------------------------------------------------------------
  #++
  ## 垂線の足のある位置の u からの比率 k を求める
  def footPointRatioFrom(_point, _extendP = true)
    _diff = self.diffVector() ;
    _rVec = @u - _point ;
    _d = _diff.sqLength() ;
    if(_d == 0.0)	# to avoid zero divide
        _k = 0.0 ;
    else
      k = _diff.innerProd(_rVec) / _d ;
    end

    ## adjust k if non-extendP mode.
    if(!_extendP) then
      if(_k < 0.0)
        _k = 0.0 ;
      elsif(_k > 1.0)
        _k = 1.0 ;
      end
    end
      
    return _k ;
  end

  #------------------------------------------
  #++
  ## 垂線の足のある位置の u からの距離を求める
  def footPointSpanFrom(_point, _extendP = true)
    _k = footPointRatioFrom(_point, _extendP) ;
    return _k * length() ;
  end

  #------------------------------------------
  #++
  ## 垂線の足のある位置。extendP が false の時は線分としての最近点
  def footPointFrom(_point, _extendP = false)
    _k = footPointRatioFrom(_point, _extendP) ;

    _foot = @u + diffVector().amplify(_k) ;

    return _foot ;
  end
  
  #--////////////////////////////////////////////////////////////
  # bbox and min/max XYZ
  #--------------------------------------------------------------
  #++
  ## minX
  def minX()
    return min(@u.x, @v.x) ;
  end

  #------------------------------------------
  #++
  ## maxX
  def maxX()
    return max(@u.x, @v.x) ;
  end

  #--------------------------------------------------------------
  #++
  ## minY
  def minY()
    return min(@u.y, @v.y) ;
  end

  #------------------------------------------
  #++
  ## maxY
  def maxY()
    return max(@u.y, @v.y) ;
  end

  #--------------------------------------------------------------
  #++
  ## minZ
  def minZ()
    return min(@u.z, @v.z) ;
  end

  #------------------------------------------
  #++
  ## maxZ
  def maxZ()
    return max(@u.z, @v.z) ;
  end
  

  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class LineSegment
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
    ## init, dup
    def test_a
      line0 = LineSegment.new() ;
      p [:line0, line0] ;
      line1 = LineSegment.new([1,2,3],[5,6,7]) ;
      p [:line1, line1] ;
      line2 = line1.dup() ;
      p [:line2, :dup, line2] ;
      line3 = line1.reverse() ;
      p [:line3, :rev, line3] ;
    end

    #----------------------------------------------------
    #++
    ## distance, min/max
    def test_b
      line0 = LineSegment.new([1,0,-1],[-1,4,3]) ;
      p [:line0, line0] ;
      p [:length, line0.length()] ;
      p [:min, line0.minX(), line0.minY(), line0.minZ()] ;
      p [:max, line0.maxX(), line0.maxY(), line0.maxZ()] ;
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
