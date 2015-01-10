require 'rest_client'
require 'nokogiri'
require 'json'
require 'iconv'
require 'uri'
require_relative 'course.rb'
# 難得寫註解，總該碎碎念。
class Spider
  attr_reader :semester_list, :courses_list, :query_url, :result_url

  def initialize
  	@query_url = "http://www.m.sanmin.com.tw/Product/Scheme1/?id="
    @front_url = "http://www.m.sanmin.com.tw/"
    @end_url = "&index="
  end

  def prepare_post_data
    puts "hey yo bestwise here"
    
    # r = RestClient.get @query_url
    # ic = Iconv.new("utf-8//translit//IGNORE","utf-8")
    # @query_page = Nokogiri::HTML(ic.iconv(r.to_s))
    # puts @query_page
    nil
  end

  def get_books
  	# 初始 courses 陣列
    @books = []
    puts "getting books...\n"
    # 一一點進去YO
    @time_start = Time.now
    10.times do |page|
      sleep 1.0
      puts "now on collection #{page}"

      r = RestClient.get @query_url + (page).to_s
      ic = Iconv.new("utf-8//translit//IGNORE","utf-8")
      query_page = Nokogiri::HTML(ic.iconv(r.to_s))
      
      # get every page in collection
      query_page.css('td.weblblue13_2').each_with_index do |row, index|
        sleep 1.0
        # get url
        puts index, row.css('a').first['href']
        puts @query_url + row.css('a').first['href'].to_s
        r = RestClient.get @front_url + row.css('a').first['href'].to_s
        ic = Iconv.new("utf-8//translit//IGNORE","utf-8")
        hello = Nokogiri::HTML(ic.iconv(r.to_s))

        # get total page in every small collection
        puts "counts #{hello.css('span.purple16:nth-of-type(1)').text}"
        counts = hello.css('span.purple16:nth-of-type(1)').text.to_i / 20.0
        pages = counts.ceil
          
        pages.times do |page|
          puts "now on small #{page+1}"
          sleep 1
          r = RestClient.get @front_url + row.css('a').first['href'].to_s + @end_url + (page+1).to_s
          ic = Iconv.new("utf-8//translit//IGNORE","utf-8")
          small_hello = Nokogiri::HTML(ic.iconv(r.to_s))

          small_hello.css('td.blue16').each_with_index do |row, index|
            sleep 0.4
            puts row.css('a').first['href']
            # get detail page here
            r = RestClient.get @front_url + row.css('a').first['href'].to_s
            ic = Iconv.new("utf-8//translit//IGNORE","utf-8")
            detail_hello = Nokogiri::HTML(ic.iconv(r.to_s))

            puts detail_hello.css('span.ProdName').text
            # every list
            @book_name = detail_hello.css('span.ProdName').text
            @series = "" 
            @isbn13 = "" 
            @another_book_name = "" 
            @author = "" 
            @page_covering = "" 
            @edition = "" 
            @size = ""
            @publish_store = "" 
            @publish_date = "" 
            detail_hello.css('ul.ProdInfo li').each_with_index do |row, index|
              if row.text.rpartition('：').first == "作者"
                @author = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first.rpartition(' ').last == "系列名"
                @series = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first.rpartition(' ').last == "ISBN13"
                @isbn13 = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "替代書名"
                @another_book_name = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "裝訂／頁數"
                @page_covering = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "版次"
                @edition = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "規格(高/寬/厚)"
                @size = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "出版社"
                @publish_store = row.text.rpartition('：').last
              elsif row.text.rpartition('：').first == "出版日"
                @publish_date = row.text.rpartition('：').last
              end
            end

            @books << Course.new({
                :book_name => @book_name,
                :series => @series,
                :isbn13 => @isbn13,
                :another_book_name => @another_book_name,
                :author => @author,
                :page_covering => @page_covering,
                :edition => @edition,
                :size => @size,
                :publish_store => @publish_store,
                :publish_date => @publish_date
              }).to_hash
            # puts @series,@isbn13,@another_book_name,@author,@page_covering,@edition,@size,@publish_store,@publish_date
          end
        end
      end
      puts ""
      @time_end = Time.now
      puts "Total crawling time: #{@time_start-@time_start} seconds"
    end



    
  end
  

  def save_to(filename='courses_p1.json')
    File.open(filename, 'w') {|f| f.write(JSON.pretty_generate(@books))}
  end
    
end






spider = Spider.new
spider.prepare_post_data
spider.get_books
spider.save_to