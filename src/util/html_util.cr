require "../models/page_result"

module HtmlUtil
  extend self

  def get_cp_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_CP_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_CP_Center", 17, -13)
  end

  def get_hp_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_HP_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_HP_Center", 17, -13)
  end

  def get_hp_warn_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_HPWarn_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_HPWarn_Center", 17, -13)
  end

  def get_hp_fill_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_HPFill_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_HPFill_Center", 17, -13)
  end

  def get_mp_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_MP_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_MP_Center", 17, -13)
  end

  def get_exp_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_EXP_bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_EXP_Center", 17, -13)
  end

  def get_food_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_Food_Bg_Center", "L2UI_CT1.Gauges.Gauge_DF_Large_Food_Center", 17, -13)
  end

  def get_weight_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool) : String
    get_gauge(width, current, max, display_as_percentage, Util.map(current, 0, max, 1, 5))
  end

  def get_weight_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool, level : Int64) : String
    get_gauge(width, current, max, display_as_percentage, "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_bg_Center#{level}", "L2UI_CT1.Gauges.Gauge_DF_Large_Weight_Center#{level}", 17, -13)
  end

  private def get_gauge(width : Int32, current : Int64, max : Int64, display_as_percentage : Bool, background_image : String, image : String, image_height : Int64, top : Int64) : String
    current = Math.min(current, max)

    String.build do |io|
      io << "<table width="
      io << width
      io << " cellpadding=0 cellspacing=0><tr><td background=\""
      io << background_image
      io << "\"><img src=\""
      io << image
      io << "\" width="
      io << ((current // max) &* width).to_i64
      io << " height="
      io << image_height
      io << "></td></tr><tr><td align=center><table cellpadding=0 cellspacing="
      io << top
      io << "><tr><td>"
      if display_as_percentage
        io << "<table cellpadding=0 cellspacing=2><tr><td>"
        io.printf("%.2f", (current / max) * 100)
        io << "</td></tr></table>"
      else
        td_width = (width &- 10) // 2
        io << "<table cellpadding=0 cellspacing=0><tr><td width="
        io << td_width
        io << " align=right>"
        io << current
        io << "</td><td width=10 align=center>/</td><td width="
        io << td_width
        io << ">"
        io << max
        io << "</td></tr></table>"
      end
      io << "</td></tr></table></td></tr></table>"
    end
  end

  def create_page(elements : Enumerable(T), page : Int32, elements_per_page : Int32, pager_function : Int32 -> String, body_function : T -> String) : PageResult forall T
    create_page(elements, elements.size, page, elements_per_page, pager_function, body_function)
  end

  def create_page(elements : Enumerable(T), size : Int32, page : Int32, elements_per_page : Int32, pager_function : Int32 -> String, body_function : T -> String) : PageResult forall T
    pages = size // elements_per_page
    if elements_per_page * pages < size
      pages &+= 1
    end

    pager_template = String::Builder.new

    if pages > 1
      break_it = 0
      pages.times do |i|
        pager_template << pager_function.call(i)
        break_it &+= 1
        if break_it > 5
          pager_template << "</tr><tr>"
          break_it = 0
        end
      end
    end

    if page >= pages
      page = pages &- 1
    end

    start = 0
    if page > 0
      start = elements_per_page &* page
    end

    sb = String::Builder.new
    elements.each_with_index do |element, i|
      if i < start
        next
      end
      sb << body_function.call(element)
      if i >= elements_per_page &+ start
        break
      end
    end

    PageResult.new(pages, pager_template, sb)
  end
end
