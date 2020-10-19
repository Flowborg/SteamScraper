require 'nokogiri'
require 'open-uri'
require 'watir'

$names = Array.new(50)
$steam_prices = Array.new(50)
$gog_prices = Array.new(50)

def scrapper
  selection = 10
  while selection != "0"
    puts "1) Scrape Steam\n2) Scrape GOG\n3) Compare prices\n0) Exit"
    selection = gets.strip
    case selection

    when "1"

      puts "Title                                                     Price     "
      puts "*************************************************************************"

      url = "https://store.steampowered.com/search/?filter=globaltopsellers&os=win"
      parsed_page = Nokogiri::HTML(URI.open(url))
      listings = parsed_page.css("div#search_result_container a")

      i = 0
      listings.each do |game|
        $names[i] = game.css("span.title").text
        $steam_prices[i] = game.css("div.search_price").text.strip

        count = 0
        $steam_prices[i].each_char do |c|
          if c == '$'
            count = count + 1
            if count == 2
              if $steam_prices[i][5] == '$'
                $steam_prices[i] = $steam_prices[i][5..$steam_prices[i].length]
              elsif $steam_prices[i][6] == '$'
                $steam_prices[i] = $steam_prices[i][6..$steam_prices[i].length]
              end
              if $steam_prices[i][0] != '$'
                $steam_prices[i] = $steam_prices[i][1..$steam_prices[i].length]
              end
            end
          end
        end
        puts($names[i].ljust(58) + $steam_prices[i])
        i=i+1
      end
      $names.pop(4)

    when "2"
      browser = Watir::Browser.new
      puts "Title                                                     Price     "
      puts "*************************************************************************"

      i = 0
      $names.each do |title|
        temp = title.clone
        temp.gsub!(/—/, '')
        temp.gsub!(/™/, '')
        temp.gsub!(/®/, '')
        temp.gsub!(/\s/, '%20')
        temp.gsub!(/'/, '%27')
        url = "https://www.gog.com/games?page=1&sort=popularity&search=" + temp
        browser.goto url
        sleep 2
        parsed_page = Nokogiri::HTML(browser.html)
        if parsed_page.at_css("div.product-tile")
          tiles = parsed_page.css("div.product-tile")
          $gog_prices[i] = tiles.first['track-add-to-cart-price']
          puts($names[i].ljust(58) + $gog_prices[i])
        end
        i=i+1
      end
      puts "\n\n"

    when "3"
      i = 0
      puts "Title                                                     Price     "
      puts "*************************************************************************"
      $names.each do |title|
        if $gog_prices[i] != nil && $steam_prices[i][1..5].to_f < $gog_prices[i][1..5].to_f
          puts($names[i].ljust(58) + $steam_prices[i].ljust(12) + "STEAM")
        elsif $gog_prices[i] != nil && $steam_prices[i][1..5].to_f > $gog_prices[i][1..5].to_f
          puts($names[i].ljust(58) + $gog_prices[i].ljust(12) + "GOG")
        else
          puts($names[i].ljust(58) + $steam_prices[i].ljust(12) + "STEAM")
        end
        i += 1
      end
      puts "\n\n"

    when "0"
      puts "goodbye"

    else
      puts "\ninvalid selection: " + selection + "\n\n"
    end
  end
end
scrapper


