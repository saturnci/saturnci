module NavigationHelper
  def visit_build_tab(tab_slug, job:)
    visit job_path(job, tab_slug)
    expect(page).to have_content(original_job.system_logs) # To prevent race condition
  end

  def navigate_to_build(build)
    # It's important that we visit the other job via Turbo,
    # not via a full page reload
    click_on "build_link_#{build.id}"
    expect(page).to have_content("Commit: #{build.commit_hash}") # to prevent race condition
  end

  def navigate_to_build_tab(tab_slug, job:)
    click_on tab_slug.titleize

    value = job.send(tab_slug)
    raise "Can't use job.#{tab_slug} to prevent race condition because job.#{tab_slug} is nil" if value.nil?

    expect(page).to have_content(value) # to prevent race condition
  end

  def navigate_to_job_tab(job)
    click_on job.name
    expect(page).to have_content(job.system_logs) # to prevent race condition
  end
end
