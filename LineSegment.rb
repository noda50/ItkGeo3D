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

#$LOAD_PATH.addIfNeed("~/lib/ruby");
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
      return self.new(*_aValue) ;
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
  def self.sureLineSegment(_aValue) ;
    return self.sureGeoObject(_aValue) ;
  end
  
  #------------------------------------------
  #++
  ## ensure a Point
  ## _aValue_:: a Point, Vector or [_x_, _y_]
  ## *return* :: a Point
  def sureLineSegment(_aValue) ;
    return sureGeoObject(_aValue) ;
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
  ## length
  ## *return*:: length of LineSegment.
  def length()
    return @u.distanceTo(@v)
  end

  #------------------------------------------
  #++
  ## direction(difference) Vector
  ## _unitP_:: if false, return difference vector of @v and @u.
  ##           if true, return unit vector.
  ##           if numeric, return unit vector of a certain length.
  ## *return*:: a direction Vector.
  def direction(_unitP = true)
    _diff = @v - @u ;
    _unitP = 1.0 if(_unitP && !_unitP.is_a?(Numeric)) ;
    if(_unitP) then
      return _diff.unit(_unitP) ;
    else
      return _diff ;
    end
  end

  #------------------------------------------
  #++
  ## length on a certain direction
  ## _dir_:: a Vector of direction.
  ## *return*:: length of LineSegment along to the direction
  def lengthOn(_dir)
    return self.direction(false).innerProd(_dir) ;
  end

  #------------------------------------------
  #++
  ## angle of direction with another LineSegment.
  ## _line_:: another LineSegment
  ## *return*:: angle in Rad.
  def angleWith(_line)
    _cos = self.cosWith(_line) ;
    _cos = Geo3D.bound(_cos, -1.0, 1.0) ; ## for safety.

    return Math.acos(_cos) ;
  end

  #------------------------------------------
  #++
  ## angle with another LineSegment in degree
  ## _line_:: another LineSegment
  ## *return*:: angle in Deg
  def angleWithInDeg(_line)
    return rad2deg(angleWith(_line)) ;
  end

  #------------------------------------------
  #++
  ## cosine value direction vector with another LineSegment
  ## _line_:: another LineSegment
  ## *return*:: a difference Vector.
  def cosWith(_line)
    _line = self.class()::sureGeoObject(_line) ;
    _inner = self.direction(true).innerProd(_line.direction(true)) ;
    return _inner ;
  end

  #--////////////////////////////////////////////////////////////
  #--------------------------------------------------------------
  #++
  ## 線分の途中。
  ## _midPoint_ = _frac_ * @v + (1 - _frac_) * @u
  ## _frac_:: 割合
  ## *return*:: Point
  def midPoint(_frac = 0.5)
    return @v.midPointWith(@u, _frac) ;
  end

  #--////////////////////////////////////////////////////////////
  # 垂線
  #--------------------------------------------------------------
  #++
  ## 垂線の足のある位置の u からの比率 k を求める
  ## _point_:: 垂線推薦を下ろす点。
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  def footPointFractionFrom(_point, _extendP = true)
    _diff = self.direction(false) ;
    _rVec = _point - @u ;
    _d = _diff.sqLength() ;
    _k = ((_d == 0.0) ? 0.0 : (_diff.innerProd(_rVec).to_f / _d) ) ;

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
  ## _point_:: 垂線を下ろす点
  ## _extendP_:: 線分の延長線上を許すかどうか。許さない場合、端点となる。
  def footPointSpanFrom(_point, _extendP = true)
    _frac = footPointFractionFrom(_point, _extendP) ;
    return _frac * length() ;
  end

  #------------------------------------------
  #++
  ## 垂線の足(最近点)のある位置。extendP が false の時は線分としての最近点
  ## _point_:: 垂線を下ろす点
  ## _extendP_:: 線分の延長線上を許すかどうか。許さない場合、端点となる。
  def footPointFrom(_point, _extendP = false)
    _k = footPointFractionFrom(_point, _extendP) ;

    _foot = @u + direction(false).amp(_k) ;

    return _foot ;
  end


  #--////////////////////////////////////////////////////////////
  # 2線分の最近点
  #--------------------------------------------------------------
  #++
  ## 2つの線分の最近点の分率対を求める。
  ## 考え方：
  ##   線分 U:(U0,U1), V:(V0,V1) を考える。U0,U1,V0,V1 は端点を表すベクトル。
  ##     U上の点 Rp= (1-p) U0 + p U1 。
  ##     V上の点 Rq= (1-q) V0 + q V1 。
  ##   線分R:(Rp,R1)とすると、
  ##     Rの方向 = Rq-Rp = q(V1-V0) - p(U1-U0) + (V0-U0)
  ##   線分 R:(Rp,Rq) は U, V に直交する。よって、
  ##     (Rq-Rp)(U1-U0) = 0
  ##     (Rq-Rp)(V1-V0) = 0
  ##   よって、
  ##     q(U1-U0)(V1-V0) - p(U1-U0)^2 + (V0-U0)(U1-U0) = 0
  ##     q(V1-V0)^2 - p(U1-U0)(V1-V0) + (V0-U0)(V1-V0) = 0
  ##   ここで、
  ##     a = (U1-U0)^2
  ##     b = (V1-V0)^2
  ##     c = (U1-U0)(V1-V0)
  ##     g = (V0-U0)(U1-U0)
  ##     h = (V0-U0)(V1-V0)
  ##   としておくと、(以下、2行で行列・ベクトル)
  ##     [-a c] [p] = [-g]
  ##     [-c b] [q] = [-h]
  ##   左辺の行列の行列式は det = c^2 - ab となるので、
  ##   [p,q] の解は、
  ##     [p] = 1/    [b -c] [-g]
  ##     [q] =  /det [c -a] [-h]
  ##   つまり、
  ##     p = (1/det) (-bg + ch)
  ##     q = (1/det) (-cg + ah)
  ##   なお、det = 0 となるのは、
  ##     ab = c^2
  ##   つまり、
  ##     (U1-U0)^2 (V1-V0)^2 = ((U1-U0)(V1-V0))^2
  ##   これは、線分U,Vが平行の場合。
  ##   この場合は、p=q=0 として問題はない。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: [p,q] の組。
  def closestFractionPairFrom(_line, _extendP = false)
    _dU = self.direction(false) ;
    _dV = _line.direction(false) ;
    _dUV = _line.u - self.u ;
    _a = _dU.innerProd(_dU) ;
    _b = _dV.innerProd(_dV) ;
    _c = _dU.innerProd(_dV) ;
    _g = _dUV.innerProd(_dU) ;
    _h = _dUV.innerProd(_dV) ;
    _det = _c**2 - _a * _b ;

    if(isAlmostZero(_det)) then
      _p = 0.0 ;
      _q = 0.0 ;
    else
      _p = (_c * _h - _b * _g).to_f/_det ;
      _q = (_a * _h - _c * _g).to_f/_det ;
    end

    if(!_extendP) then
      _newP = _p ;
      _newQ = _q ;
      _newP = 0.0 if(_p < 0.0) ;
      _newP = 1.0 if(_p > 1.0) ;
      _newQ = 0.0 if(_q < 0.0) ;
      _newQ = 1.0 if(_q > 1.0) ;
      if(_newP != _p && _newQ != _q) then
        _p = _newP ;
        _q = _newQ ;
      elsif(_newP != _p) then ## 一方だけ端点の場合、計算し直し。
        _pointP = (_newP == 0.0 ? self.u : self.v) ;
        _q = _line.footPointFractionFrom(_pointP, _extendP) ;
        _p = _newP ;
      elsif(_newQ != _q) then ## 一方だけ端点の場合、計算し直し。
        _pointQ = (_newQ == 0.0 ? _line.u : _line.v) ;
        _p = self.footPointFractionFrom(_pointQ, _extendP) ;
        _q = _newQ ;
      else
        # do nothing
      end
    end

    return [_p, _q] ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最近点を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: self と _line_ 上の点の組 [p,q]。
  def closestPointPairFrom(_line, _extendP = false)
    (_p, _q) = self.closestFractionPairFrom(_line, _extendP) ;
    _pointP = self.midPoint(_p) ;
    _pointQ = _line.midPoint(_q) ;
    return [_pointP, _pointQ] ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最短距離を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: 最短距離。
  def closestDistanceFrom(_line, _extendP = false)
    (_pointP, _pointQ) = self.closestPointPairFrom(_line, _extendP) ;
    return _pointP.distanceTo(_pointQ) ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最短距離となる線分を求める。
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: 最短距離となる LineSegment
  def closestLineSegmentFrom(_line, _extendP = false)
    (_pointP, _pointQ) = self.closestPointPairFrom(_line, _extendP) ;
    return self.class.new(_pointP, _pointQ) ;
  end

  #------------------------------------------
  #++
  ## 2つの線分の最短距離となる点などの情報をまとめて取得
  ## _line_:: もう一つの LineSetment
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: [_distance_, _lineSegment_, [_fracSelf_, _fracOther_]]
  ##            _lineSegment_:: 最短距離となる線分。
  def distanceInfoToLine(_line, _extendP = false)
    (_fracSelf, _fracOther) = self.closestFractionPairFrom(_line, _extendP) ;
    _line = self.class.new(self.midPoint(_fracSelf),
                           _line.midPoint(_fracOther)) ;
    return [_line.length(), _line, [_fracSelf, _fracOther]] ;
  end

  alias distanceInfoToLineSegment distanceInfoToLine ;

  #----------------------
  #++
  ## 頂点との距離情報
  ## _point_:: a Point
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: distance
  def distanceToLine(_line, _extendP = false)
    return distanceInfoToLine(_line, _extendP).first ;
  end
  
  alias distanceToLineSegment distanceToLine ;
  
  #------------------------------------------
  #++
  ## 頂点との距離情報
  ## _point_:: a Point
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: [_distance_, _footPoint_, _frac_]
  ##            _frac_:: 垂線の足の線分上の分率。
  def distanceInfoToPoint(_point, _extendP = false)
    _frac = self.footPointFractionFrom(_point, _extendP) ;
    _foot = self.footPointFrom(_point, _extendP) ;
    
    return [_point.distanceTo(_foot), _foot, _frac] ;
  end

  #----------------------
  #++
  ## 頂点との距離情報
  ## _point_:: a Point
  ## _extendP_:: 足として線分外も許すかどうか。
  ##             線分外を許さない(false)の場合、どちらかの端点(0 or 1)となる。
  ## *return*:: distance
  def distanceToPoint(_point, _extendP = false)
    return distanceInfoToPoint(_point, _extendP).first ;
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
  # convert
  #--------------------------------------------------------------
  #++
  ## to array
  def to_a()
    return [@u.to_a, @v.to_a] ;
  end

  #------------------------------------------
  #++
  ## to Hash
  def to_h()
    return { u: @u.to_h, v: @v.to_h } ;
  end

  #------------------------------------------
  #++
  ## to json
  def toJson()
    return { class: self.class.to_s, u: @u.toJson(), v: @v.toJson()} ;
  end

  #--========================================
  #------------------------------------------
  #++
  ## new from Json
  ## *return* :: a Vector
  def self.newByJson(_json)
    _line = self.new(self::PointClass::newByJson(_json[:u]),
                     self::PointClass::newByJson(_json[:v])) ;
    return _line ;
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
end # class LineSegment
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

    #----------------------------------------------------
    #++
    ## 垂線
    def test_c
      l0 = LineSegment.new([0,0,0],[1,1,1]) ;
      p0 = Point.new([0,1,0]) ;
      p1 = Point.new([0,-1,0]) ;      
      p [:lp, l0.toJson, p0.to_a, p1.to_a] ;
      foot00 = l0.footPointFrom(p0) ;
      foot01 = l0.footPointFrom(p0,true) ;
      foot10 = l0.footPointFrom(p1) ;
      foot11 = l0.footPointFrom(p1,true) ;
      p [:foot00, foot00.to_a] ;
      p [:foot01, foot01.to_a] ;
      p [:foot10, foot10.to_a] ;
      p [:foot11, foot11.to_a] ;
      fl00 = LineSegment.new(p0, foot00) ;

      gconf = {
        styleTable: {
          l0: { lw: 3, lc: "red" },
          p0: { lw: 1, lc: "blue" },
          p1: { lw: 1, lc: "gold" },
          foot00: { lw: 2, lc: "0x88009955" },
          foot01: { lw: 2, lc: "0x88999900" },
          foot10: { lw: 2, lc: "0x88990055" },
          foot11: { lw: 2, lc: "0x8800FF00" },
          fl00: { lw: 2, lc: "0x8800FF00" },
        },
      } ;
      
      Gnuplot::directMulti3dPlot([:l0, :p0, :p1,
                                  :foot00, :foot01,
                                  :foot10, :foot11,
                                  :fl00,
                                 ], gconf){|gplot|
        l0.draw(gplot, :l0) ;
        p0.draw(gplot, :p0) ;
        p1.draw(gplot, :p1) ;
        foot00.draw(gplot, :foot00) ;
        foot01.draw(gplot, :foot01) ;
        foot10.draw(gplot, :foot10) ;
        foot11.draw(gplot, :foot11) ;
        fl00.draw(gplot, :fl00) ;
      }
    end

    #----------------------------------------------------
    #++
    ## 線分との最近線分(closest with line)
    def test_d
      l0 = LineSegment.new([0,0,0],[1,1,1]) ;
      l1 = LineSegment.new([1,0,0],[1,1,0]) ;
      l2 = LineSegment.new([-1,0,-1],[-1,0,1]) ;
      p [:ll, l0.to_a, l1.to_a, l2.to_a] ;
      
      d01 = l0.closestLineSegmentFrom(l1) ;
      p [:d01, d01.to_a] ;
      d02 = l0.closestLineSegmentFrom(l2) ;
#      d02 = l0.closestLineSegmentFrom(l2, true) ;
      p [:d02, d02.to_a] ;

      gconf = {
        styleTable: {
        },
      } ;
      Gnuplot::directMulti3dPlot([:l0, :l1, :l2, :d01, :d02], gconf){|gplot|
        l0.draw(gplot, :l0) ;
        l1.draw(gplot, :l1) ;
        l2.draw(gplot, :l2) ;
        d01.draw(gplot, :d01) ;
        d02.draw(gplot, :d02) ;
      }
    end

    #----------------------------------------------------
    #++
    ## cosine and angle
    def test_e
      l0 = LineSegment.new([0,1,1],[0,0,0]) ;
      l1 = LineSegment.new([0,1,1],[1,1,0]) ;
      p [:l01, l0.to_a, l1.to_a] ;
      p [:angleDeg01, l0.angleFromInDeg(l1)] ;
      p [:angleDeg10, l1.angleFromInDeg(l0)] ;
      p [:angleDeg00, l0.angleFromInDeg(l0)] ;
    end

    #----------------------------------------------------
    #++
    ## 線分との最近線分(closest with line) again
    def test_d
      bar1 = LineSegment.new([8,3,3],[5,2,5]) ;
      baz1 = LineSegment.new([2,2,2],[7,2,7]) ;

      (dist, segment, fracPair) = bar1.distanceInfoToLine(baz1) ;

      p [:dist, dist] ;
      
      gconf = { xlabel: "X", ylabel: "Y", zlabel: "Z"} ;
      Gnuplot::directMulti3dPlot([:bar1, :baz1, :segment], gconf){|gplot|
        bar1.draw(gplot, :bar1) ;
        baz1.draw(gplot, :baz1) ;
        segment.draw(gplot, :segment) ;
      }
    end

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
