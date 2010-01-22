require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module MyScriptsTest
  module A
    class B
      class C
      end
    end
  end

  describe String do
    context '#to_class' do
      it 'converts string into appropriate Class constant' do
        "Fixnum".to_class.should == Fixnum
        "MyScriptsTest::A::B::C".to_class.should == MyScriptsTest::A::B::C
      end

      it 'returns nil if string is not convertible into class' do
        "Math".to_class.should == nil
        "Math::PI".to_class.should == nil
        "Something".to_class.should == nil
      end

      it 'deals with leading colons' do
        "::MyScriptsTest::A::B::C".to_class.should == MyScriptsTest::A::B::C
      end
    end
  end
end