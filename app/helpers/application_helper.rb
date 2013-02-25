module ApplicationHelper
  def javascript(*files)
    content_for(:actionjavascripts) { javascript_include_tag(*files) }
  end
end
