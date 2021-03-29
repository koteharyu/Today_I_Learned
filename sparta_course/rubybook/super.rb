class Item
  def name
    @name
  end
  def name=(text)
    @name = text
  end
  def full_name # 1
    @name
  end
end

class Drink < Item
  def size
    @size
  end
  def size=(text)
    @size
  end
  def full_name #2
    super # 3
  end
end

item = Item.new
item.name = "haryu"

drink = Drink.new
drink.name = "latte"
drink.size = "tall"

puts drink.full_name #=> latte

puts "#{drink.name} #{item.name} yes"