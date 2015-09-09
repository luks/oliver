require "modules/logger.rb"


class Test

  include Logging

  def fibonacci(n)
    n = n.to_i
    if n < 2
      return n
    end
    return fibonacci(n - 2) + fibonacci(n - 1)
  end


  #super brzi nacin za racunanje fibonacia
  def fib_r(a, b, n)
    n == 0 ? a : fib_r(b, a + b, n - 1)
  end

  def fib(n)
    n = n.to_i
    return fib_r(0, 1, n)
  end

  def exception
    logger.info "In test exception"
    raise "this is a test exception"
  end
  def handle(*job)
    i = 0
    1000000.times do |t|
      i+=1
    end
    i
  end

  def handle2(job)
    random_comic_url = []
    case job
      when "test1"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test2"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test3"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test4"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test5"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test6"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test7"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test8"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test9"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test10"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test11"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']
      when "test12"
        response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
        random_comic_url = response['Location']

      end
     return random_comic_url
  end

end



# Uvod:
#     Cela finta vpodstate spociva v tom, ze kdyz volame nejakou funkci  (obecne),
#   tak potrebujeme nekam zaznamenat, kam se po jejim skonceni  vratit, a tim
#   padem komu predat navratovou hodnotu.
#   To misto, kam tyhle informace davame nazyvame stackem/zasobnikem.

# Ilustarce 1:
#   unsigned long long int factorial(unsigned long long int n)
#   /* unsigned long long musi stacit vsem    */
#   {
#       if (n == 0) return 1;
#       return n * factorial(n - 1);
#   }

#   V tomhle konkretnim pripade nam zasobnik slouzi k tomu abychom po te co nam
#   factorial(n - 1) neco vrati, mohli to neco vynasobit cislem n.

# Optimalizace:
#   Jenze, v pripade, ze mame rekurzi a rekurentni volani je az uplne  nakonci,
# dostaneme situaci, ze informace kam se vratit je uplne  zbytecna, protoze po
# vraceni z funkce se zase akorat vratime dal (s  vysledkem volani uz nic
# nedelame a zas ho rovnou vracime - cili ta funkce uz defakto skoncila i pres to,
# ze rekurentne vola samu sebe). Tim padem, my vubec nemusime nejakej stack udrzovat
# pri rekurentnich  volani, nemame zadnou informaci kterou bychom na ten stack mohli
# dat a  zaroven by nam k necemu byla dobra - postaci nam, ze se budeme umet  vratit
# tam, od kde byl vstup do ty samotny rekuze.
# Takze misto toho, abychom do stacku pridavali, tak nam staci menit parametry puvodni
# funkce v aktualnim framu a skakat pokazde zpet na zacatek.

#   Obrovskou vyhodou je, ze takto muzeme elegantne a prirozene zapisovat
# v principu rekurentni algoritmy a pritom stroj algoritmus nebude  provadet vylozene
# rekurentne a tim padem nam nedojde stack + ziskame  rychlost navic.
# Takze takovy faktorial, aby nemel na konci nic jinyho nez return  factorial(...)
# muzeme prepsat takto:

# Ilustrace 2
#   unsigned long long int factorial_tail(int n, unsigned long long int acc)
#   /* kdo to pustil, vi, ze unsigned long long je k prdu  */
#   {
#       if (n == 0) return acc;
#       return factorial_tail(n - 1, n * acc);
#   }

# pozn1: snad sem to vysvetlil nejak srozumitelne
# pozn2: z kompilatoru se kterymi pracuju (a co vim) to dela gcc a steel  bank common lisp,
# a pak asi vsechny implementace scheme o kterejch se ma  cenu bavit. Myslim, ze java ma
# nejakou castecnou podporu taky.


# RubyVM::InstructionSequence.compile_option = {
#   tailcall_optimization: true,
#   trace_instruction: false }
# RubyVM::InstructionSequence.new(<<-EOF).eval   def factorial_rec(n, acc=1)     return acc if n <= 1     factorial_rec(n-1, n*acc)   end EOF  puts "#{n}: #{factorial_rec(n)}"
