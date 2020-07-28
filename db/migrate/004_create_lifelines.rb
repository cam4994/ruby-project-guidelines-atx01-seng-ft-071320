class CreateLifelines < ActiveRecord::Migration[5.2]
    def change
        create_table :lifelines do |t|
            t.string :name 
            t.boolean :available
        end
    end
end