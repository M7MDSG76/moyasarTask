class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.string :token
    end
    add_index :api_tokens, :token, unique: true
  end
end
