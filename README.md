# ![LendingHome](https://cloud.githubusercontent.com/assets/2419/19467866/7efa93a8-94c8-11e6-93e7-4375dbb8a7bc.png) zero_downtime_migrations

Zero downtime migrations with ActiveRecord and PostgreSQL. Catch problematic migrations at development/test time!

Heavily insprired by the similar projects listed below. Our intent was to target PostgreSQL specific issues and provide clearer instructions on how to perform the migrations the "zero downtime way".

* https://github.com/ankane/strong_migrations
* https://github.com/foobarfighter/safe-migrations

## Installation

Simply add the gem to the project `Gemfile`. Ensure that it's only added to the `development` and `test` groups.

```ruby
gem "zero_downtime_migrations", only: %i(development test)
```

## Usage

This gem will automatically raise exceptions when potential database locking migrations are detected. It checks for common things like:

* Adding a column with a default
* Adding a non-concurrent index
* Mixing data changes with index or schema migrations
* Performing data or schema migrations with the DDL transaction disabled
* Using `each` instead of `find_each` to loop thru `ActiveRecord` objects

These exceptions display clear instructions of how to perform the same operation the "zero downtime way".

## Disabling exceptions

We can disable any of these "zero downtime migration" enforcements by wrapping them in a `safety_assured` block.

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    safety_assured do
      add_column :posts, :published, :boolean, default: true
    end
  end
end
```

We can also disable the exceptions by setting `ENV["SAFETY_ASSURED"]` when running migrations.

```bash
SAFETY_ASSURED=1 bundle exec rake db:migrate --trace
```

These enforcements are automatically disabled by default for the following scenarios:

* We're loading the database schema with `rake db:schema:load` instead of `db:migrate`
* We're migrating down (reverting a migration)

## Validations

### Adding a column with a default

#### Bad

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published, :boolean, default: true
  end
end
```

#### Good

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published, :boolean
  end
end
```

```ruby
class SetPublishedDefaultOnPosts < ActiveRecord::Migration[5.0]
  def change
    change_column_default :posts, :published, true
  end
end
```

```ruby
class BackportPublishedDefaultOnPosts < ActiveRecord::Migration[5.0]
  def change
    Post.select(:id).find_in_batches.with_index do |batch, index|
      puts "Processing batch #{index}\r"
      Post.where(id: batch).update_all(published: true)
    end
  end
end
```

### Adding an index concurrently

#### Bad

```ruby
class IndexUsersOnEmail < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :email
  end
end
```

#### Good

```ruby
class IndexUsersOnEmail < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

### Mixing data/index/schema migrations

#### Bad

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published, :boolean
    Post.update_all(published: true)
    add_index :posts, :published
  end
end
```

#### Good

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published, :boolean
  end
end
```

```ruby
class BackportPublishedOnPosts < ActiveRecord::Migration[5.0]
  def change
    Post.update_all(published: true)
  end
end
```

```ruby
class IndexPublishedOnPosts < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :posts, :published, algorithm: :concurrently
  end
end
```

### Disabling the DDL transaction

#### Bad

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :posts, :published, :boolean
  end
end
```

```ruby
class UpdatePublishedOnPosts < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    Post.update_all(published: true)
  end
end
```

#### Good

```ruby
class AddPublishedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :published, :boolean
  end
end
```

```ruby
class UpdatePublishedOnPosts < ActiveRecord::Migration[5.0]
  def change
    Post.update_all(published: true)
  end
end
```

### Looping thru `ActiveRecord::Base` objects

#### Bad

```ruby
class BackportPublishedDefaultOnPosts < ActiveRecord::Migration[5.0]
  def change
    Post.all.each do |post|
      post.update_attribute(published: true)
    end
  end
end
```

#### Good

```ruby
class BackportPublishedDefaultOnPosts < ActiveRecord::Migration[5.0]
  def change
    Post.all.find_each do |post|
      post.update_attribute(published: true)
    end
  end
end
```

### TODO

* Changing a column type
* Removing a column
* Renaming a column
* Renaming a table

## Testing

```bash
bundle exec rspec
```

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
* Commit, do not mess with the version or history.
* Open a pull request. Bonus points for topic branches.

## License

[MIT](https://github.com/lendinghome/zero_downtime_migrations/blob/master/LICENSE) - Copyright © 2016 LendingHome
