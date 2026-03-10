module DashboardHelper
  # Renders a sortable column header link.
  # Clicking the active column toggles asc/desc; clicking a new column defaults to asc.
  # Preserves existing filter params in the URL so sorting doesn't wipe active filters.
  def sort_link(label, column, table:, current_sort:, current_dir:)
    active    = current_sort == column
    next_dir  = (active && current_dir == "asc") ? "desc" : "asc"
    indicator = active ? (current_dir == "asc" ? " ↑" : " ↓") : ""

    link_params = params.permit(:matter_type, :task_status,
                                :matters_sort, :matters_dir,
                                :tasks_sort,   :tasks_dir)
                        .merge("#{table}_sort" => column, "#{table}_dir" => next_dir)

    link_to "#{label}#{indicator}", dashboard_path(link_params),
            class: ("sort-active" if active)
  end
end
