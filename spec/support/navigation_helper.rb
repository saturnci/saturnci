module NavigationHelper
  def visit_build_tab(tab_slug, run:)
    visit task_path(run, tab_slug)
  end

  def navigate_to_build(build)
    # It's important that we visit the other run via Turbo,
    # not via a full page reload
    click_on "test_suite_run_link_#{build.id}"
    expect(page).to have_content("Commit: #{build.commit_hash}") # to prevent race condition
  end

  def navigate_to_build_tab(tab_slug, run:)
    click_on tab_slug.titleize

    value = run.send(tab_slug)
    raise "Can't use run.#{tab_slug} to prevent race condition because run.#{tab_slug} is nil" if value.nil?

    expect(page).to have_content(value) # to prevent race condition
  end

  def navigate_to_run_tab(run)
    click_on run.name
    expect(page).to have_content(run.runner_system_log.content) # to prevent race condition
  end
end
