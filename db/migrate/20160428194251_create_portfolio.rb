class CreatePortfolio < ActiveRecord::Migration
  def change
  	create_table :portfolios do |t|
  	  t.index :id
      t.string :hipchat_username
      t.string :stock_name
      t.integer :stock_amount
 	  t.decimal :purchase_price_per
      t.timestamps 

    end
  end
end
