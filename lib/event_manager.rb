require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
        address: zipcode,
        levels: 'country',
        roles: %w(legislatorUpperBody legislatorLowerBody)
    ).officials

  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_numbers(phone_number)

  phone_number.gsub!(/[^\d]/, "")
  number_length = phone_number.length
  return "Is bad number" unless number_length.between?(9, 11)
  return phone_number if number_length == 10
  return phone_number[1..9] if (number_length == 11) && (phone_number[0] == "1") else "Is bad number"

end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol
template_letter = File.read "form_letter.html"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_numbers(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  # save_thank_you_letters(id, form_letter)

  puts "#{name} #{row[:homephone]} #{phone_number}"
end
