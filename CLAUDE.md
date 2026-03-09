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

## Models

### Matter (`app/models/matter.rb`)
Represents a legal matter being tracked.

| Field | Type | Notes |
|-------|------|-------|
| `title` | string | Required |
| `client` | string | Legacy string field (see `client_id`) |
| `matter_type` | string | One of: Family Law, Criminal, Conveyancing, Commercial |
| `status` | string | One of: Open, Pending, Closed (default: Open) |
| `due_date` | date | Optional |
| `description` | text | Optional |
| `client_id` | integer | FK → clients |

Associations: `belongs_to :client` (optional), `has_many :tasks`, `has_many :notes`
Scopes: `open`, `pending`, `closed`, `by_due_date`

---

### Client (`app/models/client.rb`)
A person or entity being represented.

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | Required |
| `email` | string | Optional, validated format |
| `phone` | string | Optional |
| `address` | text | Optional |

Associations: `has_many :matters`
Scopes: `alphabetical`

---

### Task (`app/models/task.rb`)
A task or action item associated with a matter.

| Field | Type | Notes |
|-------|------|-------|
| `title` | string | Required |
| `description` | text | Optional |
| `due_date` | date | Optional |
| `status` | string | One of: Pending, In Progress, Completed (default: Pending) |
| `priority` | string | One of: Low, Medium, High (default: Medium) |
| `matter_id` | integer | Foreign Key → matters, required |

Associations: `belongs_to :matter`
Scopes: `pending`, `in_progress`, `completed`, `by_due_date`, `high_priority`

---

### Note (`app/models/note.rb`)
A timestamped note attached to a matter.

| Field | Type | Notes |
|-------|------|-------|
| `body` | text | The note content |
| `matter_id` | integer | FK → matters, required |

Associations: `belongs_to :matter`
