class RepositoryComponent < ViewComponent::Base
  renders_one :body

  def initialize(repository, extra_css_classes: nil)
    @repository = repository
    @extra_css_classes = extra_css_classes
  end
end
