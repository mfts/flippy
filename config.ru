require 'sinatra'
require 'net/http'
require 'json'
require 'nokogiri'
require 'open-uri'

InvalidTokenError = Class.new(Exception)

post '/' do
  raise(InvalidTokenError) unless params[:token] == "kzDhF1PCHAdYHo23O4IKkq16"

  user = params.fetch('user_name')
  text = params.fetch('text').strip

  case text
  when 'when'

    <<-TEXT
The next Hey! event will be held on the 20th May from 7:30pm at The Belgrave in central Leeds.

Hopefully see you then #{user}!

http://hey.wearestac.com/
TEXT

  when 'what'

    <<-TEXT
The next Hey! event has two lectures planned. The first one is with Rich Fiddaman discussing everything hospitality. The second is with Matt Dix discussing Leeds Indie Food Festival.

http://hey.wearestac.com/lectures/a-pint-with-the-pub-landlord

http://hey.wearestac.com/lectures/kickstarting-a-city-wide-food-festival
TEXT

  when 'facebook'

  query = '50838870'
  url = "http://burdahackday.finanzen100.de/v1/stock/snapshot?CHART_VARIANT=CHART_VARIANT_1&IDENTIFIER_TYPE=STOCK&IDENTIFIER_VALUE=#{query}"
  response = Net::HTTP.get_response(URI.parse(url))
  data = JSON.parse(response.body)

  name = data['CHART']['INSTRUMENT']['NAME']
  image = data['CHART']['M6']
  
  <<-TEXT
  #{name}
  TEXT

  else

    query = text.to_s

    if query.split(' ').length > 1
      query = query.split(' ').join('+')
    end
    puts query
    url1 = 'http://www.finanzen100.de/suche/'
    url = url1 + query
    io = open(url)
    body = io.read
    aaa = io.base_uri.to_s

    value1 = aaa.split('_').last.match('\d+')

    value1 = value1.to_s

    puts value1


    #value2
    doc = Nokogiri::HTML(open(url))

    aab = doc.xpath('//td[@class="NAME"]/a').map { |link| link['href'] }[0]

    value2 = aab.split('_').last.match('\d+')

    value2 = value2.to_s
    puts value2

    if value1 == '100'
      value = value2
    else
      value = value1
    end

    url = "http://burdahackday.finanzen100.de/v1/stock/snapshot?CHART_VARIANT=CHART_VARIANT_1&IDENTIFIER_TYPE=STOCK&IDENTIFIER_VALUE=#{value}"
    response = Net::HTTP.get_response(URI.parse(url))
    data = JSON.parse(response.body)

    name = data['BASE_DATA']['NAME_COMPANY']
    quote = data['QUOTE']['PRICE']
    mcunit = data['BASE_DATA']['MARKET_CAP_UNIT']
    mounit = data['QUOTE']['UNIT']
    marketcap = data['BASE_DATA']['MARKET_CAP']
    pct = data['QUOTE']['PERFORMANCE_PCT_1_YEAR']

    <<-TEXT
    Company Name: #{name}
    Stock Price (now): #{quote} #{mounit} 
    1-YR Performance : #{pct}
    Market Capitalization: #{marketcap} #{mcunit}
    TEXT

  end
end

run Sinatra::Application
