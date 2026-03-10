puts "Seeding database..."

# Clients
clients = Client.create!([
  { name: "Margaret Fitzpatrick", email: "m.fitzpatrick@gmail.com", phone: "0412 334 892", address: "14 Rosewood Drive, Toorak VIC 3142" },
  { name: "Chen & Associates Pty Ltd", email: "admin@chenassociates.com.au", phone: "03 9281 4400", address: "Level 8, 200 Collins Street, Melbourne VIC 3000" },
  { name: "Darren Okafor", email: "darren.okafor@hotmail.com", phone: "0438 771 203", address: "3/27 Harbour Street, Pyrmont NSW 2009" },
  { name: "Priya Nair-Srinivasan", email: "priya.nair@outlook.com", phone: "0401 556 119", address: "88 Thornton Avenue, Ascot QLD 4007" },
  { name: "Westbrook Holdings Pty Ltd", email: "legal@westbrookholdings.com.au", phone: "02 8235 6600", address: "Suite 1200, 1 Market Street, Sydney NSW 2000" }
])

margaret, chen, darren, priya, westbrook = clients
puts "Created #{clients.count} clients"

# Skip the after_create callback so we can seed status changes with realistic past dates
Matter.skip_callback(:create, :after, :record_initial_status)

matters = [
  Matter.create!(client: margaret, title: "Fitzpatrick — Property Settlement", matter_type: "Family Law", status: "Open", due_date: Date.today + 45, description: "Division of matrimonial assets following separation. Property at Toorak and investment portfolio to be divided."),
  Matter.create!(client: margaret, title: "Fitzpatrick — Intervention Order Application", matter_type: "Family Law", status: "Pending", due_date: Date.today + 14, description: "Application for family violence intervention order against respondent."),
  Matter.create!(client: chen, title: "Chen Associates — Commercial Lease Dispute", matter_type: "Commercial", status: "Open", due_date: Date.today + 30, description: "Dispute with landlord over rent abatement during COVID-19 lockdowns. Claim amount: $240,000."),
  Matter.create!(client: chen, title: "Chen Associates — Shareholder Agreement Review", matter_type: "Commercial", status: "Closed", description: "Review and redraft of shareholder agreement following entry of new investors."),
  Matter.create!(client: darren, title: "Okafor — Assault Charges", matter_type: "Criminal", status: "Open", due_date: Date.today + 21, description: "Client charged with common assault following altercation. First mention listed in Local Court."),
  Matter.create!(client: priya, title: "Nair-Srinivasan — Purchase of 88 Thornton Ave", matter_type: "Conveyancing", status: "Open", due_date: Date.today + 28, description: "Residential property purchase. Contract of sale exchanged. Settlement due in 28 days."),
  Matter.create!(client: priya, title: "Nair-Srinivasan — Sale of Sunnybank Property", matter_type: "Conveyancing", status: "Pending", due_date: Date.today + 60, description: "Sale of investment property at 12 Banksia Road, Sunnybank Hills QLD."),
  Matter.create!(client: westbrook, title: "Westbrook — Supply Agreement Drafting", matter_type: "Commercial", status: "Open", due_date: Date.today + 10, description: "Drafting master supply agreement with three tier-1 retail clients. NDA already in place."),
  Matter.create!(client: westbrook, title: "Westbrook — Employment Dispute (Harrison)", matter_type: "Commercial", status: "Open", due_date: Date.today + 35, description: "Unfair dismissal claim by former CFO James Harrison. Conciliation scheduled with Fair Work Commission.")
]

Matter.set_callback(:create, :after, :record_initial_status)

puts "Created #{matters.count} matters"

# Status histories with realistic past dates
MatterStatusChange.create!([
  # Fitzpatrick — Property Settlement: opened 6 weeks ago
  { matter: matters[0], status: "Open",    created_at: 6.weeks.ago },

  # Fitzpatrick — IVO: opened 5 weeks ago, moved to Pending 2 weeks ago
  { matter: matters[1], status: "Open",    created_at: 5.weeks.ago },
  { matter: matters[1], status: "Pending", created_at: 2.weeks.ago },

  # Chen — Commercial Lease: opened 8 weeks ago
  { matter: matters[2], status: "Open",    created_at: 8.weeks.ago },

  # Chen — Shareholder Agreement: opened 5 months ago, closed 3 weeks ago
  { matter: matters[3], status: "Open",    created_at: 5.months.ago },
  { matter: matters[3], status: "Closed",  created_at: 3.weeks.ago },

  # Okafor — Assault: opened 4 weeks ago
  { matter: matters[4], status: "Open",    created_at: 4.weeks.ago },

  # Priya — Purchase: opened 3 weeks ago
  { matter: matters[5], status: "Open",    created_at: 3.weeks.ago },

  # Priya — Sale: opened 10 weeks ago, moved to Pending 4 weeks ago
  { matter: matters[6], status: "Open",    created_at: 10.weeks.ago },
  { matter: matters[6], status: "Pending", created_at: 4.weeks.ago },

  # Westbrook — Supply Agreement: opened 2 weeks ago
  { matter: matters[7], status: "Open",    created_at: 2.weeks.ago },

  # Westbrook — Employment Dispute: opened 7 weeks ago
  { matter: matters[8], status: "Open",    created_at: 7.weeks.ago },
])

puts "Created status histories"

# Tasks
[
  { matter: matters[0], title: "Obtain property valuations", priority: "High", status: "In Progress", due_date: Date.today + 7, description: "Commission independent valuations for Toorak home and beach house." },
  { matter: matters[0], title: "Request financial disclosure documents", priority: "High", status: "Pending", due_date: Date.today + 10, description: "Send Section 13 disclosure request to opposing solicitor." },
  { matter: matters[0], title: "File Form 1 — Initiating Application", priority: "Medium", status: "Pending", due_date: Date.today + 14, description: "Lodge initiating application in Federal Circuit Court." },
  { matter: matters[0], title: "Brief counsel for interim hearing", priority: "Medium", status: "Pending", due_date: Date.today + 30, description: "Prepare brief for Counsel re interim property orders." },
  { matter: matters[1], title: "File IVO application at Magistrates Court", priority: "High", status: "Completed", description: "Filed — receipt obtained." },
  { matter: matters[1], title: "Prepare client for hearing", priority: "High", status: "In Progress", due_date: Date.today + 12, description: "Conference with client to prepare evidence and statement." },
  { matter: matters[1], title: "Obtain affidavit from client", priority: "High", status: "Pending", due_date: Date.today + 7, description: "Draft and swear supporting affidavit." },
  { matter: matters[2], title: "Review lease agreement", priority: "High", status: "Completed", description: "Reviewed 2019 commercial lease — relevant clauses identified." },
  { matter: matters[2], title: "Draft letter of demand", priority: "High", status: "In Progress", due_date: Date.today + 5, description: "Formal demand to landlord for $240k rent abatement." },
  { matter: matters[2], title: "File VCAT application if no response", priority: "Medium", status: "Pending", due_date: Date.today + 20, description: "Prepare VCAT application in the event demand is not met within 14 days." },
  { matter: matters[4], title: "Obtain brief of evidence from Police", priority: "High", status: "In Progress", due_date: Date.today + 5, description: "Request full brief from arresting officer." },
  { matter: matters[4], title: "First mention — Local Court appearance", priority: "High", status: "Pending", due_date: Date.today + 21, description: "Appear at Downing Centre Local Court for first mention." },
  { matter: matters[4], title: "Advise client on plea options", priority: "Medium", status: "Pending", due_date: Date.today + 14, description: "Conference with Darren re plea and likely sentencing range." },
  { matter: matters[5], title: "Review contract of sale", priority: "High", status: "Completed", description: "Contract reviewed — special conditions noted." },
  { matter: matters[5], title: "Conduct title searches", priority: "High", status: "Completed", description: "Title clear — no encumbrances." },
  { matter: matters[5], title: "Arrange building and pest inspection", priority: "Medium", status: "In Progress", due_date: Date.today + 5, description: "Coordinate inspector with agent — report expected within 5 days." },
  { matter: matters[5], title: "Prepare settlement statement", priority: "Medium", status: "Pending", due_date: Date.today + 25, description: "Calculate adjustments for rates, water and body corporate." },
  { matter: matters[7], title: "Draft master supply agreement", priority: "High", status: "In Progress", due_date: Date.today + 7, description: "Initial draft — incorporate client's standard liability cap and IP ownership clauses." },
  { matter: matters[7], title: "Client review of first draft", priority: "Medium", status: "Pending", due_date: Date.today + 9, description: "Send to Westbrook board for internal sign-off." },
  { matter: matters[8], title: "File Form F3 — Employer Response", priority: "High", status: "Pending", due_date: Date.today + 7, description: "Lodge employer response to Harrison's unfair dismissal application." },
  { matter: matters[8], title: "Prepare for FWC conciliation", priority: "High", status: "Pending", due_date: Date.today + 30, description: "Review Harrison's personnel file and prepare chronology of events." },
  { matter: matters[8], title: "Obtain witness statements from HR team", priority: "Medium", status: "Pending", due_date: Date.today + 20, description: "Statements from 3 HR staff re performance management process." }
].each { |attrs| Task.create!(attrs) }

puts "Created tasks"
puts "Done."
