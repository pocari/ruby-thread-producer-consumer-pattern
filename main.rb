require 'thread'

q = Queue.new
threads = 5.times.map do
  Thread.new do
    p [:start, Thread.current.object_id]
    loop do
      i = q.pop
      # consuemrは終了用のフラグを受け取るまでループ
      break if i.nil?
      sleep 0.5
      p [i, Thread.current.object_id]
    end
    p [:stop, Thread.current.object_id]
  end
end

producer = Thread.new(threads.count) do |consumers|
  20.times do |i|
    q.push(i)
  end

  # consumerの件数分終了用のフラグになる値をqueueにいれる(ここではnil)
  consumers.times do
    q.push(nil)
  end
end

# 終了フラグを設けて、各threadを明示的に処理終了させないと、このjoinで、
# `join': No live threads left. Deadlock? (fatal)`
# のエラーになってしまう
[producer, *threads].each(&:join)