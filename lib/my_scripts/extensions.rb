# encoding: UTF-8

class String
  TRANSLIT_CYRILLIC = 'АБВГДЕЁЗИЙКЛМНОПРСТУФЪЫЬЭабвгдеёзийклмнопрстуфъыьэ'
  TRANSLIT_LATIN = "ABVGDEEZIJKLMNOPRSTUF\"Y'Eabvgdeezijklmnoprstuf\"y'e"
  TRANSLIT_DOUBLES = {'Ж'=>'ZH', 'Х'=>'KH', 'Ц'=>'TS', 'Ч'=>'CH', 'Ш'=>'SH', 'Щ'=>'SHCH', 'Ю'=>'YU', 'Я'=>'YA',
                      'ж'=>'zh', 'х'=>'kh', 'ц'=>'ts', 'ч'=>'ch', 'ш'=>'sh', 'щ'=>'shch', 'ю'=>'yu', 'я'=>'ya'}
  
  def translit!
    TRANSLIT_DOUBLES.each {|key, value| self.gsub!(key, value)}
    self.tr!(TRANSLIT_CYRILLIC, TRANSLIT_LATIN)
    self
  end

  # Turns string into appropriate class constant, returns nil if class not found
  def to_class
    klass = self.split("::").inject(Kernel) do |namespace, const|
      const == '' ? namespace : namespace.const_get(const)
    end
    klass.is_a?(Class) ? klass : nil
  rescue NameError
    nil
  end


end
