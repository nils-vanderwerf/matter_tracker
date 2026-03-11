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
- Write tests with RSpec + FactoryBot (specs in `spec/`)

## Git Commit Conventions
- Each commit should represent one logical part of the build (e.g. a feature, a model, a set of specs)
- Do not commit incremental or work-in-progress changes — squash into a single meaningful commit before pushing
- Commit messages should be descriptive but concise: `Add notes feature`, `Add RSpec model specs with FactoryBot`
- If commits accumulate, squash into logical groups with `git rebase -i` before pushing

## Running the App
```bash
cd matter_tracker
bundle exec rails db:create db:migrate
bundle exec rails server
```

## Running Tests
```bash
bundle exec rspec
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
- `db/migrate/` — database migrations
- `spec/` — RSpec specs (models in `spec/models/`, request specs in `spec/controllers/`)
- `spec/factories/` — FactoryBot factories
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

Associations: `belongs_to :client` (optional), `has_many :tasks`, `has_many :notes`, `has_many :status_changes`
Scopes: `open`, `pending`, `closed`, `overdue`, `by_due_date`
Methods: `close`, `reopen`, `closed?`, `overdue?`
Callbacks: records initial status on create; records a `MatterStatusChange` whenever `status` changes

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
Scopes: `pending`, `in_progress`, `completed`, `by_due_date`, `high_priority`, `overdue`

---

### Note (`app/models/note.rb`)
A timestamped note attached to a matter.

| Field | Type | Notes |
|-------|------|-------|
| `body` | text | The note content |
| `matter_id` | integer | FK → matters, required |

Associations: `belongs_to :matter`
Routes: `create`, `destroy`, `edit`, `update` only (no index/show — notes are displayed inline on the matter show page)

---

### MatterStatusChange (`app/models/matter_status_change.rb`)
An audit record created automatically whenever a matter's status changes.

| Field | Type | Notes |
|-------|------|-------|
| `status` | string | The new status value at time of change |
| `matter_id` | integer | FK → matters |
| `created_at` | datetime | When the change occurred |

Associations: `belongs_to :matter`
Never created manually — driven entirely by `Matter` callbacks.

---

## Dashboard (`app/controllers/dashboard_controller.rb`)
Root page (`/`). Displays:
- **Stat cards**: Open Matters, Pending Matters, Overdue Matters, Overdue Tasks (always global, unaffected by filters)
- **Overdue Matters table**: matters not closed with `due_date < today`
- **Upcoming Deadlines table**: open/pending matters due within 14 days
- **High Priority Tasks table**: incomplete High priority tasks, past due dates highlighted red

**Filtering**: `matter_type` param filters both matter tables; `task_status` param filters the tasks table.

**Sorting**: all columns sortable via `matters_sort`/`matters_dir` and `tasks_sort`/`tasks_dir` params. Column map is whitelisted in `MATTER_SORT_COLUMNS` / `TASK_SORT_COLUMNS` to prevent SQL injection. Sort state is preserved in the URL alongside filter params. Helper: `DashboardHelper#sort_link`.

All queries use `includes` (or `eager_load` when sorting by an association column) to avoid N+1 loads.
