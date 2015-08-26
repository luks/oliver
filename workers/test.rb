require_relative "../modules/logger.rb"

module Oliver
  class Test
    include Logger
    def test(n)
      n.times do |i|
        logger.info "From test::test #{i}"
      end
    end
  end
end