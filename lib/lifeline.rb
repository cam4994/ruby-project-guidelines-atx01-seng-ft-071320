class Lifeline < ActiveRecord::Base
    belongs_to :user

    def self.get_lifeline_fifty
        self.find_by(name: "fifty_fifty")
    end

    def self.get_lifeline_cut
        self.find_by(name: "cut_question")
    end

    def self.activate_fifty_fifty


    end

    def self.activate_cut_question
    
    end
end