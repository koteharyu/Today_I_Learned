array = [10, 8, 3, 5, 2, 4, 11, 18, 20, 33]
index = array.size
sorted_array = []
i = 1

while i < index do
  mx = array.max
  array.delete(mx)
  sorted_array.unshift(mx)
  i += 1
end

p sorted_array
