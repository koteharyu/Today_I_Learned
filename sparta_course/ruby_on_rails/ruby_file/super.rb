class Base
  def message
    puts "baseのタイトル"
  end
end

class Task < Base
    def message
      super
      puts "baseを継承"
    end
end

t = Task.new
puts t.message