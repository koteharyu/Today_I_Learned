## rubyにおける`ARVGメソッド`とは

<br>

コマンドライン引数を取得できるメソッド

```
# foo.rb

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
```
`$ ruby foo.rb 30`のように、コマンドラインから引数を指定することができるため

汎用性がかなり高くなる

[注意]

AVRG[0]のように、このメソッドは配列となるため

取り出し方に注意！！