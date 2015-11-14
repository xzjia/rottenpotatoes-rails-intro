class Movie < ActiveRecord::Base
    def self.all_ratings
        result = []
        Movie.all.each do |m|
            if !(result.include? m.rating)
                result.push m.rating
            end
        end
        return result
    end
end
