require 'prawn/layout'
require 'prawn/format'

pdf.tags :h1 => { :font_size => "2em", :font_weight => :bold },
:h2 => { :font_size => "0.5em", :font_weight => :bold },
:title => { :font_weight => :bold, :font_size => "1.5em" },
:indent => { :width => "2em" },
:event_data => { :color => 'black', :align => :justify },
:event_title => { :color => 'black', :font_weight => :bold },
:high => { :color => "red", :align => :left },
:medium => { :color => 'yellow', :align => :left },
:low => { :color => 'green', :align => :left }
snorby_logo = "public/images/PDF/snorby_logo.png"
high_i = "public/images/PDF/high.png"
medium_i = "public/images/PDF/medium.png"
low_i = "public/images/PDF/low.png"
pdf.line_width(1)

### GET DATA
@h_c = []
@h = []
@m_c = []
@m = []
@l_c = []
@l = []

@report.count_events.each do |event, count|
  r = event.split('|')
  sig_name = r[0]
  src_ip = IPAddr.new_ntoh([r[1].to_i].pack('N'))
  dest_ip = IPAddr.new_ntoh([r[2].to_i].pack('N'))
  severity = r[3].to_i
  sensor = r[4].to_i
  @h_c << [count, sig_name, src_ip, dest_ip, severity, sensor] if severity == 1
  @h << count if severity == 1
  @m_c << [count, sig_name, src_ip, dest_ip, severity, sensor] if severity == 2
  @m << count if severity == 2
  @l_c << [count, sig_name, src_ip, dest_ip, severity, sensor] if severity == 3
  @l << count if severity == 3
end
### END

### Start Of Cover

pdf.move_down(100)
pdf.image snorby_logo, :scale=>0.7, :position => :center
pdf.text "#{@report.rtype.capitalize} Security Report", :size => 25, :style => :bold, :align => :center
pdf.text "This report was generated: #{Time.now.strftime('%A, %B %d, %Y')}", :size => 12, :style => :bold, :align => :center

pdf.move_down(30)
pdf.start_new_page

###

### Summary
pdf.move_down(2)
pdf.text "#{@report.rtype.capitalize} Report Summary", :size => 20, :style => :bold, :align => :center
pdf.stroke_horizontal_rule
pdf.move_down(50)
if !@h.blank? and !@m.blank? and !@l.blank?
  begin
    pdf.image open(Gchart.line(:line_color => ["adffa2", "f8f9a4", "fb9c9c"], :labels => ["Low", "Medium", "High"], :data => [@l, @m, @h], :size => '500x230')), :position => :center
  rescue
    pdf.text "Error Creating Graphs.", :size => 15, :style => :bold, :align => :left
  end
end
pdf.move_down(30)
header = ["Low Severity", "Medium Severity", "High Severity", "Total Event Count"]
pdf.table [[pluralize(@l_c.size, "Event"), pluralize(@m_c.size, "Event"), pluralize(@h_c.size, "Event"), pluralize(@report.events.size, "Event")]],
:headers => header,
:position => :center,
:width => 500,
:border_width => 1,
:font_size => 12
pdf.move_down(20)
begin
  pdf.image open(Gchart.pie_3d(:line_color => ["adffa2", "f8f9a4", "fb9c9c"], :labels => ["Low (#{@l.size})", "Medium (#{@m.size})", "High (#{@h.size})"], :data => [@l.size, @m.size, @h.size], :size => '440x200')), :position => :center
rescue
  pdf.move_down(40)
  pdf.text "Error Creating Graphs.", :size => 15, :style => :bold, :align => :left
end
pdf.move_down(40)
pdf.start_new_page

### END

### Start Of Data
pdf.header [pdf.margin_box.left, pdf.margin_box.top + 20] do
  pdf.text "- #{Time.now.strftime('%A, %B %d, %Y')} - #{@report.rtype.capitalize} Snorby Report. -", :size => 7, :align => :center, :style => :italic, :color => 'black'
  pdf.move_down 2
  pdf.stroke_horizontal_rule
  pdf.move_down 30
end

pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 5] do
  pdf.move_down 7
  pdf.stroke_horizontal_rule
  pdf.move_down 3
  pdf.text "- #{pdf.page_count} -", :size => 7, :align => :center
  pdf.move_down 1
  pdf.text "Copyright (c) Snorby.org", :size => 7, :align => :center, :style => :italic, :color => 'black'
end

unless @h_c.blank?
  pdf.move_down(20)
  pdf.text "High Severity", :size => 20, :style => :bold, :align => :left
  h = 0
  @h_t_data = Array.new
  pdf.move_down(10)
  @h_c.each do |event|
    h += 1
    @h_t_data << ["#{event[1]}", "#{event[5]}", "#{event[2]}", "#{event[3]}", "#{pluralize(event[0], "Session")}"]
  end
  h_header = ["Event Name", "Sensor", "Source Address", "Destination Address", "Session Count"]
  pdf.table @h_t_data,
  :headers => h_header,
  :position => :center,
  :width => 535,
  :border_width => 1,
  :font_size => 10
end

unless @m_c.blank?
  pdf.move_down(20)
  pdf.text "Medium Severity", :size => 20, :style => :bold, :align => :left
  m = 0
  @m_t_data = Array.new
  pdf.move_down(10)
  @m_c.each do |event|
    m += 1
    @m_t_data << ["#{event[1]}", "#{event[5]}", "#{event[2]}", "#{event[3]}", "#{pluralize(event[0], "Session")}"]
  end
  m_header = ["Event Name", "Sensor", "Source Address", "Destination Address", "Session Count"]
  pdf.table @m_t_data,
  :headers => m_header,
  :position => :center,
  :width => 535,
  :border_width => 1,
  :font_size => 10
end

unless @l_c.blank?
  pdf.move_down(20)
  pdf.text "Low Severity", :size => 20, :style => :bold, :align => :left
  h = 0
  @l_t_data = Array.new
  pdf.move_down(10)
  @l_c.each do |event|
    h += 1
    @l_t_data << ["#{event[1]}", "#{event[5]}", "#{event[2]}", "#{event[3]}", "#{pluralize(event[0], "Session")}"]
  end
  l_header = ["Event Name", "Sensor", "Source Address", "Destination Address", "Session Count"]
  pdf.table @l_t_data,
  :headers => l_header,
  :position => :center,
  :width => 535,
  :border_width => 1,
  :font_size => 10
end
### End Of Data