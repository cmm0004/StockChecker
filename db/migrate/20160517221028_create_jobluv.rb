
class CreateJobluv < ActiveRecord::Migration
  def change

  	create_table :jobluvs do |t|
      t.string :hipchat_username
      t.integer :jobluv_amount
      t.boolean :is_the_job_don

      t.timestamps 

    end
  end
end
