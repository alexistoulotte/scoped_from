ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: File.expand_path("#{__dir__}/../../test.sqlite3"), timeout: 5000)

ActiveRecord::Base.connection.create_table(:comments, force: true)
ActiveRecord::Base.connection.create_table(:posts, force: true)
ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
  t.string :firstname, null: false
  t.string :lastname, null: false
  t.boolean :enabled, null: false, default: false
  t.boolean :admin, null: false, default: false
  t.timestamps null: false
end
ActiveRecord::Base.connection.create_table(:votes, force: true)
