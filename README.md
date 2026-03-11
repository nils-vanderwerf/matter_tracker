# Matter Tracker

I am applying for a role at [Clio](https://www.clio.com/au/) and wanted to show up with more than a CV. Built this to get my head around the domain - a stripped back version of what Clio does.

Tracks legal matters for a law firm. Clients have matters, matters have tasks and notes, everything has a status and due date.

Built with [Claude Code](https://claude.ai/code) as a pair programmer - I directed it, reviewed what it produced, and pushed back when it went off track.

---

## What it does

- **Dashboard** - stat cards, overdue matters, upcoming deadlines, high priority tasks. Filterable by matter type and task status, all columns sortable
- **Clients** - create and manage clients, overdue due dates highlighted
- **Matters** - track by type, status and due date. Close and reopen with full status history. Overdue badge when past due and still open
- **Tasks** - attached to matters with priority and status, overdue indicator on incomplete past-due tasks
- **Notes** - add notes to any matter, shown inline

## Screenshots

**Dashboard**
![Dashboard](screenshots/dashboard.png)

**Dashboard - filtered by matter type and priority**
![Dashboard filtered](screenshots/dashboard_filtered.png)

**Overdue matter**
![Overdue matter](screenshots/matter_overdue.png)

**Client page**
![Client page](screenshots/client_show.png)

**Matter detail**
![Matter detail](screenshots/matter_show.png)

**Editing a note**
![Editing a note](screenshots/notes_edit.png)

---

## Data model

```
Client             → has many Matters
Matter             → belongs to Client, has many Tasks, Notes, MatterStatusChanges
Task               → belongs to Matter
Note               → belongs to Matter
MatterStatusChange → belongs to Matter (audit log, written on every status change)
```

## How data flows

Rails MVC - every request goes through three layers:

- **Routes** (`config/routes.rb`) - maps URL + HTTP verb to a controller action
- **Controller** - receives the request, reads/writes via the model, renders a view or redirects
- **Model** - the Ruby class wrapping the database table. Validations, associations, business logic
- **View** - ERB template that takes whatever the controller prepared and renders HTML

```
Browser → Routes → Controller → Model ↔ Database
                       ↓
                     View → Browser
```

## Setup

```bash
git clone <repo-url>
cd matter_tracker
bundle install
rails db:create db:migrate db:seed
rails server
```

Visit `http://localhost:3000`

## Tests

```bash
bundle exec rspec
```

## Stack

- Rails 7.0, SQLite3
- RSpec + FactoryBot
- Shallow nested routes
- No JavaScript framework - plain HTML, ERB, Sprockets

## What's missing

Proof of concept, not production. Next steps would be auth, time tracking, document uploads, calendar view - all things Clio does properly.
