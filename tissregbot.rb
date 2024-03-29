#### Registration Bot for TISS @ Tu Vienna ;-P ####
#### Usage: ruby tissregbot.rb ####
#### Settings ####
# Semester e.g. 2016W
semester = ARGV[0] || ""
# Course Number e.g. 015087
course = ARGV[1] || ""
# Name e.g. e0822371 
name = ARGV[2] || ""
# TISS PW
pw = ARGV[3] || ""
# Exam?
exam = ARGV[4] || "true"
# Time to check if the registration is already open (secs)
time = 0.3
######################
begin
require 'mechanize'
rescue LoadError
puts "Please install mechanize first: 'gem install mechanize'"
abort
end
if name.to_s.empty? || pw.to_s.empty? || semester.to_s.empty? || course.to_s.empty?
puts "Usage: ruby tissregbot.rb [semester] [course number] [username] [password] [exam]"
puts "E.g. ruby tissregbot.rb 2016W 015087 e0812344 password false"
abort
end
link_course = "https://tiss.tuwien.ac.at/education/course/courseRegistration.xhtml?windowId=926&semester="+semester+"&courseNr="+course.gsub('.','')
link_exam = "https://tiss.tuwien.ac.at/education/course/examDateList.xhtml?windowId=991&courseNr="+course.gsub('.','')+"&semester="+semester
agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'
page = agent.get "https://tiss.tuwien.ac.at/"
login_link = page.link_with(:text => "Login")
login_page = login_link.click()
form = login_page.form_with :action => "AuthServ.portal"
form.field_with(:name => "name").value = name
form.field_with(:name => "pw").value = pw
form.submit

if exam == "true"
	begin
	  overview = agent.get link_exam
	rescue Exception => e
	  puts "Your course number, semester or both is incorrect. Cannot find Exam."
		abort
	end
	if overview.at(".//*[@id='toolNavForm:logoutLink']/span").nil?
		puts "Your credentials seem to be incorrect"
		abort
	end
	title = /[^0-9]*([A-Za-z,-]+)[^0-9]*/.match(overview.at(".//*[@id='contentInner']/h1").text).to_s.strip

	puts "Trying to sign you up for the exam in " + title + " in " + semester
	puts "Will now reload the page every " + time.to_s + " sec. until the magic button appears"
	button = nil
	while button.nil? do
		puts "Try to find button."
		overview = agent.get link_exam
		form = overview.forms.find do |f|
	       	button = f.button_with(:value => "Anmelden")
		end
		sleep time
	end
	agent.click("Anmelden")
	agent.click("Anmelden")
	overview = agent.get link_exam
	sign_out_button_text = overview.at(".//*[@id='examDateListForm:j_id_44:0:j_id_8q']").values[3].to_s.strip
	if sign_out_button_text == "Abmelden"
		puts "Looks like everything worked fine and you are signed up for " + title + " in " + semester
	else
		puts "!! There was an error, button says " + sign_out_button_text + " but should say 'Abmelden'. Probably not signed up for" + title + " in " + semester +". Please check this in TISS !!"
	end
else
	begin
	  overview = agent.get link_course
	rescue Exception => e
	  puts "Your course number, semester or both is incorrect"
		abort
	end
	if overview.at(".//*[@id='toolNavForm:logoutLink']/span").nil?
	puts "Your credentials seem to be incorrect"
	abort
	end
	title = /[^0-9]*([A-Za-z,-]+)[^0-9]*/.match(overview.at(".//*[@id='contentInner']/h1").text).to_s.strip
	start = overview.at(".//*[@id='registrationForm:begin']").text.strip
	puts "Trying to sign you up for " + title + " in " + semester
	puts "The registration starts at " + start
	puts "Will now reload the page every " + time.to_s + " sec. until the magic button appears"
	button = nil
	while button.nil? do
		puts "Try to find button."
		overview = agent.get link_course
		form = overview.forms.find do |f|
	       	button = f.button_with(:value => "Anmelden")
		end
		sleep time
	end
	agent.click("Anmelden")
	agent.click("Anmelden")
	overview = agent.get link_course
	sign_out_button_text = overview.at(".//*[@id='registrationForm:j_id_60']").values[3].to_s.strip
	if sign_out_button_text == "Abmelden"
		puts "Looks like everything worked fine and you are signed up for " + title + " in " + semester
	else
		puts "!! There was an error, button says " + sign_out_button_text + " but should say 'Abmelden'. Probably not signed up for" + title + " in " + semester +". Please check this in TISS !!"
	end
end
