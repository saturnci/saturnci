module NavigationHelper
  def visit_build_tab(tab_slug, job:)
    visit job_path(job, tab_slug)
    expect(page).to have_content(original_job.system_logs) # To prevent race condition
  end

  def navigate_to_build(build)
    # It's important that we visit the other job via Turbo,
    # not via a full page reload
    click_on "build_link_#{build.id}"
    expect(page).to have_content("Commit: #{other_job.build.commit_hash}") # to prevent race condition
  end

  def navigate_to_build_tab(tab_slug, job:)
    click_on "System Logs"
    expect(page).to have_content(other_job.system_logs) # to prevent race condition
  end
end
