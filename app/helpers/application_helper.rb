module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        'alert-success' #green, BS-v3
      when "notice"
        'alert-info'  #blue, BS-v3
      when "alert"
        'alert-warning' #yellow, BS-v3
      when "error"
        'alert-danger'  #red, BS-v3
    end
  end
end
