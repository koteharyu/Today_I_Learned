def fizz_buzz(num)
  1.upto(num) do |n|
    if n % 3 == 0 && n % 5 == 0
      puts "FizzBuzz"
    elsif n % 3 == 0
      puts "Fizz"
    elsif n % 5 == 0
      puts "Buzz"
    else
      puts n
    end
  end
end

fizz_buzz(ARGV[0].to_i)