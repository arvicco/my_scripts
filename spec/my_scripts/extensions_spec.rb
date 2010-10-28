# encoding: UTF-8

require 'spec_helper'

module A
  class B
    class C
    end
  end
end

describe String do
  context '#snake_case' do
    it 'transforms CamelCase strings' do
      'GetCharWidth32'.snake_case.should == 'get_char_width_32'
    end

    it 'leaves snake_case strings intact' do
      'keybd_event'.snake_case.should == 'keybd_event'
    end
  end

  context '#camel_case' do
    it 'transforms underscore strings to CamelCase' do
      'get_char_width_32'.camel_case.should == 'GetCharWidth32'
    end

    it 'leaves CamelCase strings intact' do
      'GetCharWidth32'.camel_case.should == 'GetCharWidth32'
    end
  end

  context '#to_class' do
    it 'converts string into appropriate Class constant' do
      "Fixnum".to_class.should == Fixnum
      "A::B::C".to_class.should == A::B::C
    end

    it 'returns nil if string is not convertible into class' do
      "Math".to_class.should == nil
      "Math::PI".to_class.should == nil
      "Something".to_class.should == nil
    end

    it 'deals with leading colons' do
      "::A::B::C".to_class.should == A::B::C
    end
  end

  context '#translit!' do
    it 'converts string from Cyrillic to Latin translit' do
      "Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства".translit!.
              should == "SHirokaya elektrifikatsiya yuzhnykh gubernij dast moshchnyj tolchok pod\"emu sel'skogo khozyajstva"
      "ШИРОКАЯ ЭЛЕКТРИФИКАЦИЯ ЮЖНЫХ ГУБЕРНИЙ ДАСТ МОЩНЫЙ ТОЛЧОК ПОДЪЁМУ СЕЛЬСКОГО ХОЗЯЙСТВА".translit!.
              should == "SHIROKAYA ELEKTRIFIKATSIYA YUZHNYKH GUBERNIJ DAST MOSHCHNYJ TOLCHOK POD\"EMU SEL'SKOGO KHOZYAJSTVA"
    end
  end

end
