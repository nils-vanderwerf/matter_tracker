# CLAUDE.md — Matter Tracker

A Rails 7 application for tracking legal matters, tasks, and deadlines.

## Stack
- **Ruby on Rails 7.0** with SQLite3
- **No JavaScript bundler** (`--skip-javascript`)
- Uses Sprockets for assets

## Conventions
- Follow Rails MVC conventions strictly
- Keep controllers thin — business logic belongs in models or service objects
- Use `before_action` for shared logic in controllers
- Prefer `scope` over class methods on models for query logic
- Write tests in `test/` using Minitest (default Rails)

## Running the App
```bash
cd matter_tracker
bundle exec rails db:create db:migrate
bundle exec rails server
```

## Running Tests
```bash
bundle exec rails test
```

## Generating Resources
```bash
bundle exec rails generate model <Name> <field>:<type>
bundle exec rails generate controller <Name> <actions>
bundle exec rails db:migrate
```

## Database
- SQLite3 in development and test
- Schema lives in `db/schema.rb` — never edit it directly
- Use migrations for all schema changes

## Key Directories
- `app/models/` — ActiveRecord models
- `app/controllers/` — RESTful controllers
- `app/views/` — ERB templates
- `db/migrations/` — database migrations
- `test/` — Minitest test files
- `config/routes.rb` — route definitions
