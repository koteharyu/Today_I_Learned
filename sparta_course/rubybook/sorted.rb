array = [10, 8, 3, 5, 2, 4, 11, 18, 20, 33]
array_size = array.size

(array_size - 1).downto(0) do |i|
 i.times do |n|
   # ２つの要素を比べる際の、インデックスが若い方がleft, 老い方がright
   left = array[n]
   right = array[n + 1]
   if left  > right
     array[n + 1] = left
     array[n] = right
   end
 end
end

p array