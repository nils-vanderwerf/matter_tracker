# Matter Tracker

A Rails 7 application for tracking legal matters, tasks, and deadlines.

## Requirements

- Ruby 3.x
- Bundler
- SQLite3

## Setup

```bash
git clone <repo-url>
cd matter_tracker
bundle install
rails db:create db:migrate
rails server
```

Visit `http://localhost:3000`

## Running Tests

```bash
bundle exec rails test
```

## Tech Stack

- **Rails 7.0** (no JavaScript bundler)
- **SQLite3** for the database
- **Sprockets** for asset pipeline
- **Minitest** for testing

## Development Notes

- Generate models: `rails g model <Name> <field>:<type>`
- Generate controllers: `rails g controller <Name> <actions>`
- Always run `rails db:migrate` after generating migrations
- Routes defined in `config/routes.rb`
