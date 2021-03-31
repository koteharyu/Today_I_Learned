@win = 0
@lose = 0

def hand(player)
  if player == "g"
    "あなたは...グー"
  elsif player == "c"
    "あなたは...チョキ"
  elsif player == "p"
    "あなたは...パー"
  end
end

def janken
  player = gets.chomp
    cpu = "パー"
    puts "CPU...パー"
    puts hand(player)
  if player == "g"
    puts "you lose..."
    @lose += 1
  elsif player == "c"
    puts "you win!"
    @win += 1
  elsif player == "p"
    puts "あいこで..."
    janken
  end
end


puts "何本勝負?(press 1 or 3 or 5)"
times = gets.to_i
n = 1
puts "#{times}本勝負を選びました"

case times
when 1
  puts "１本目"
  puts "じゃんけん...(press g or c or p)"
  janken
  puts "#{@win}勝#{@lose}負"
when 3
  while n <= times do
    puts "#{n}本目"
    puts "じゃんけん...(press g or c or p)"
    janken
    puts "#{@win}勝#{@lose}負"
    puts "\n"
    n += 1
  end
  puts "\n"
  puts "結果"
  if @win > @lose
    puts "#{@win}勝#{@lose}負であなたの勝ち"
  else
    puts "#{@win}勝#{@lose}負であなたの負け"
  end
when 5
  while n <= times do
    puts "#{n}本目"
    puts "じゃんけん...(press g or c or p)"
    janken
    puts "#{@win}勝#{@lose}負"
    puts "\n"
    n += 1
  end
  puts "\n"
  puts "結果"
  if @win > @lose
    puts "#{@win}勝#{@lose}負であなたの勝ち"
  else
    puts "#{@win}勝#{@lose}負であなたの負け"
  end
end



