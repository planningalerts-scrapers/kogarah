require 'scraperwiki'
require 'mechanize'

# Scraping from Masterview 2.0

def scrape_page(page)
  page.at("table.rgMasterTable").search("tr.rgRow,tr.rgAltRow").each do |tr|
    tds = tr.search('td').map{|t| t.inner_html.gsub("\r\n", "").strip}
    day, month, year = tds[2].split("/").map{|s| s.to_i}
    record = {
      "council_reference" => tds[1],
      "date_received" => Date.new(year, month, day).to_s,
      "description" => tds[3].gsub("&amp;", "&").split("<br>")[0],
      "address" => tds[3].gsub("&amp;", "&").split("<br>")[1] + ", NSW",
      "date_scraped" => Date.today.to_s
    }
    p record
  end
end

url = "http://www2.kogarah.nsw.gov.au/datrackingui/modules/applicationmaster/default.aspx?page=found&1=thismonth&4a=9&6=F"

agent = Mechanize.new

# Read in a page
page = agent.get(url)

form = page.forms.first
button = form.button_with(value: " I Agree")
form.submit(button)
# It doesn't even redirect to the correct place. Ugh

page = agent.get(url)
scrape_page(page)
