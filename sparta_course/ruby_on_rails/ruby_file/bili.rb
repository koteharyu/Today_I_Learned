class Person
  def initialize(money)
    @money = money
  end

  #　億万長者か判断するためのメソッド
  def billionaire?
    money > 100000000
  end

  private
  def money
    @money
  end
end

person = Person.new(1230000000)
puts person.billionaire?
