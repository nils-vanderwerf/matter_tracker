# Matter Tracker

I'm applying for a role at [Clio](https://www.clio.com/au/) — legal practice management software — and wanted to show up with more than a CV. So I built this: a stripped-back version of what Clio does, just to prove I understand the domain and can put together a real Rails app.

It's a CRUD app for tracking legal matters. Clients have matters (cases), matters have tasks and notes, everything has a status and a due date. Not reinventing the wheel — just demonstrating I can work with the same basic concepts Clio is built around.

Built with the help of [Claude Code](https://claude.ai/code), Anthropic's AI coding tool, which I used as a pair programmer throughout — writing code alongside it, reviewing what it produced, and guiding it when it went off track.

---

## What it does

- **Dashboard** — overdue matters, upcoming deadlines, high-priority tasks, and key stats at a glance
- **Clients** — create and manage clients
- **Matters** — track legal matters by type, status, and due date; close and reopen with full status history
- **Tasks** — attach tasks to matters with priority and status
- **Notes** — add notes to any matter, displayed inline

## Data Model

```
Client             → has many Matters
Matter             → belongs to Client, has many Tasks, has many Notes, has many MatterStatusChanges
Task               → belongs to Matter
Note               → belongs to Matter
MatterStatusChange → belongs to Matter (audit log, created automatically on status change)
```

## Setup

```bash
git clone <repo-url>
cd matter_tracker
bundle install
rails db:create db:migrate
rails server
```

Visit `http://localhost:3000`

## Tests

```bash
bundle exec rspec
```

## Stack

- Rails 7.0 with SQLite3
- RSpec + FactoryBot for testing
- Shallow nested routes
- Hotwire/Turbo (no JS framework)

## What's missing (intentionally)

This is a proof-of-concept, not a production app. The obvious next steps would be authentication, time tracking, document uploads, and a proper calendar view — all things Clio does well.
