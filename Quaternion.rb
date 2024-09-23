#! /usr/bin/env ruby
## -*- mode: ruby; coding: utf-8 -*-
## = Quaternion (四元数) library
## Author:: Itsuki Noda
## Version:: 0.0 2024/09/23 I.Noda
##
## === History
## * [2024/09/23]: Create This File.
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
require 'Itk/ItkPp.rb' ;

module Itk
#--======================================================================
#++
## 四元数
class Quaternion
  include ItkPp
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #++
  ## default values for WithConfParam#getConf(_key_).
#  DefaultConf = { :bar => :baz } ;
  ## the list of attributes that are initialized by getConf().
#  DirectConfAttrList = [:bar] ;
  
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #++
  ## 実部
  attr :r, true ;
  ## 虚部 i
  attr :i, true ;
  ## 実部 j
  attr :j, true ;
  ## 実部 k
  attr :k, true ;

  #--------------------------------------------------------------
  #++
  ## initialization
  ## _r_:: real part.
  ## _i_:: imaginal i part.
  ## _j_:: imaginal j part.
  ## _k_:: imaginal k part.
  def initialize(_r = 0.0, _i = 0.0, _j = 0.0, _k = 0.0)
    set(_r, _i, _j, _k) ;
  end

  #------------------------------------------
  #++
  ## set value
  ## _r_:: real part.
  ## _i_:: imaginal i part.
  ## _j_:: imaginal j part.
  ## _k_:: imaginal k part.
  def set(_r, _i, _j, _k)
    @r = _r ;
    @i = _i ;
    @j = _j ;
    @k = _k ;
    return self ;
  end
  
  #------------------------------------------
  #++
  ## set value by Array
  ## _vals_:: an Array of value [r, i, j, k]
  def setByArray(_vals)
    set(_vals[0], _vals[1], _vals[2], _vals[3]) ;
    return self ;
  end

  #------------------------------------------
  #++
  ## set value by Hash
  ## _vals_:: a Hash of value {r: r, i: i, j: j, k: k]
  def setByHash(_vals)
    set(_vals[:r], _vals[:i], _vals[:j], _vals[:k]) ;
    return self ;
  end

  #--========================================
  #------------------------------------------
  #++
  ## ensure Quaternion
  ## _qVal_:: a Value. one of Quaternion, Array, Hash, Numeric
  def self.sure(_qVal)
    case(_qVal)
    when Quaternion ;
      return _qVal ;
    when Array ;
      return self.new().setByArray(_qVal) ;
    when Hash ;
      return self.new().setByHash(_qVal) ;
    when Numeric ;
      return self.new(_qVal) ;
    else
      raise "#{_qVal.inspect} can not convert to #{self}." ;
    end
  end
  
  #------------------------------------------
  #++
  ## ensure Quaternion
  ## _qVal_:: a Value. one of Quaternion, Array, Hash, Numeric
  def sure(_qVal)
    return self.class.sure(_qVal) ;
  end

  #------------------------------------------
  #++
  ## 等価
  ## _qVal_:: a Quaternion ;
  def ==(_qVal)
    _q = sure(_qVal) ;
    return (@r == _q.r && @i == _q.i && @j == _q.j && @k == _q.k) ;
  end
  

  #--////////////////////////////////////////////////////////////
  ## 演算
  #--------------------------------------------------------------
  #++
  ## 増加
  ## _qVal_:: 増分 
  def inc(_qVal)
    _q = sure(_qVal) ;
    @r += _q.r ;
    @i += _q.i ;
    @j += _q.j ;
    @k += _q.k ;
    return self ;
  end

  #------------------------------------------
  #++
  ## 減少
  ## _qVal_:: 減分
  def dec(_qVal)
    _q = sure(_qVal) ;
    @r -= _q.r ;
    @i -= _q.i ;
    @j -= _q.j ;
    @k -= _q.k ;
    return self ;
  end

  #------------------------------------------
  #++
  ## 拡大
  ## _qVal_:: 倍率
  def amp(_qVal)
    if(_qVal.is_a?(Numeric) && !_qVal.is_a?(self.class)) then
      @r *= _qVal ;
      @i *= _qVal ;
      @j *= _qVal ;
      @k *= _qVal ;
      return self ;
    else
      _q = sure(_qVal) ;
      _r = @r * _q.r - @i * _q.i - @j * _q.j - @k * _q.k ;
      _i = @r * _q.i + @i * _q.r + @j * _q.k - @k * _q.j ;
      _j = @r * _q.j - @i * _q.k + @j * _q.r + @k * _q.i ;
      _k = @r * _q.k + @i * _q.j - @j * _q.i + @k * _q.r ;
      @r = _r ;
      @i = _i ;
      @j = _j ;
      @k = _k ;
      return self ;
    end
  end

  #------------------------------------------
  #++
  ## 加算
  ## _qVal_:: 加算分
  def +(_qVal)
    return self.dup.inc(_qVal) ;
  end
  
  #------------------------------------------
  #++
  ## 減算
  ## _qVal_:: 減算分
  def -(_qVal)
    return self.dup.dec(_qVal) ;
  end

  #------------------------------------------
  #++
  ## マイナス
  def -@()
    return self.dup.amp(-1) ;
  end

  #------------------------------------------
  #++
  ## 乗算
  ## _qVal_:: 乗算分
  def *(_qVal)
    return self.dup.amp(_qVal) ;
  end

  #------------------------------------------
  #++
  ## 除算
  ## _qVal_:: 除算分
  def /(_qVal)
    if(_qVal.is_a?(Numeric) && !_qVal.is_a?(self.class)) then
      return self.dup.amp(1.0 / _qVal) ;
    else
      return self.dup.amp(_qVal.inv()) ;
    end
  end
  
  #------------------------------------------
  #++
  ## 逆数
  def sqNorm()
    return ((@r ** 2) + (@i ** 2) + (@j ** 2) + (@k ** 2))
  end

  #------------------------------------------
  #++
  ## 逆数
  def norm()
    return Math.sqrt(self.sqNorm()) ;
  end

  #------------------------------------------
  #++
  ## 正規化
  def normalize(_dupP = true)
    if(_dupP) then
      return self / self.norm() ;
    else
      return self.amp(1.0 / norm()) ;
    end
  end

  #------------------------------------------
  #++
  ## 共役
  def conj()
    return self.class.new(@r, -@i, -@j, -@k) ;
  end

  #------------------------------------------
  #++
  ## 逆数
  def inv()
    return conj() / sqNorm() ;
  end

  #--////////////////////////////////////////////////////////////
  ## 変換
  #--------------------------------------------------------------
  #++
  ## 配列へ
  def to_a()
    return [@r, @i, @j, @k] ;
  end

  #--------------------------------------------------------------
  #++
  ## Hashへ
  def to_h(_base = {})
    _base[:r] = @r ;
    _base[:i] = @i ;
    _base[:j] = @j ;
    _base[:k] = @k ;
    return _base ;
  end

  #--------------------------------------------------------------
  #++
  ## JSONへ
  def toJson(_base = {})
    _base[:class] = self.class ;
    return to_h(_base) ;
  end
  
  #--////////////////////////////////////////////////////////////
  #--============================================================
  #--::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  #--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  #--------------------------------------------------------------
end # class Quaternion

end # module Itk

########################################################################
########################################################################
########################################################################
if($0 == __FILE__) then

  require 'test/unit'

  include Itk ;

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
    ## init, inc, dec
    def test_a
      q0 = Quaternion.new(1,2,3,4) ;
      q1 = Quaternion.new(3,1,4,1) ;
      p [:q, q0, q1] ;
      p [:inc, q0.inc(q1)] ;
      p [:incA, q0.inc([3,3,3,3])] ;
      p [:decA, q0.dec(3)] ;
      p [:to, q0.to_a, q0.to_h, q0.toJson] ;
      p [:dup, q0.dup] ;
    end

    #----------------------------------------------------
    #++
    ## init, inc, dec
    def test_b
      q0 = Quaternion.new(2,7,1,8) ;
      q1 = Quaternion.new(3,1,4,1) ;
      p [:q, q0, q1] ;
      p [:+, q0 + q1] 
      p [:-, q0 - q1] 
      p [:*, q0 * q1] 
      p [:/, q0 / q1] 
      p [:norm, q0.norm()] ;
      p [:conj, q0.conj()] ;
      p [:inv, q0.inv()] ;
      p [:normalize, q0.normalize()] ;
      q2 = Quaternion.new(0,7,1,8) ;
      q3 = Quaternion.new(0,1,4,1) ;
      p [:mulconj, (q2 * q3), (q3 * q2), (q3 * q2).conj] ;
    end
    

  end # class TC_Foo < Test::Unit::TestCase
end # if($0 == __FILE__)
