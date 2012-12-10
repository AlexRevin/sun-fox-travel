module ApplicationHelper
  # {:url => "/foo", :icon => "icon-edit", :size => "sm", :color => "purple", :text => "foobar"}
  def button_href(*args)
    opts = args.extract_options!
    raise "no url" unless opts[:url].present?
    icon = opts[:icon] ? "<i class='#{opts[:icon]}'></i>" : ""
    link_to raw("#{icon} #{opts[:text] || ''}"), opts[:url], {:class => "m-btn #{opts[:size] || 'mini'} #{opts[:color] if opts[:color].present?}"}
  end
end
