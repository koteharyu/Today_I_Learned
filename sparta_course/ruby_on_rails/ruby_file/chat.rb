module Chat
  def chat
    puts "hello"
  end
end

class You 
  include Chat
end

y = You.new
y.chat