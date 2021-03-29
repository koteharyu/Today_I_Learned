class Item
  def name
    @name
  end
  def name=(text)
    @name = text
  end
end

class Drink < Item # 1
  def size
    @size
  end
  def size=(text)
    @size = text
  end
end

item = Item.new
item.name = "mafin"

drink = Drink.new
drink.name = "latte" # 2
drink.size = "tall"

puts "#{item.name} #{drink.size} size"