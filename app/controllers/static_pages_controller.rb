class StaticPagesController < ApplicationController
  require 'net/http'
  require 'json'

  def top
    city = params[:city] || "Otaru" # パラメータから地域を取得、デフォルトは小樽市
    @weather = fetch_weather(city)
  end

  private

  def fetch_weather(city)
    api_key = ENV['OPEN_WEATHER_MAP_API_KEY']
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}&units=metric&lang=ja"
    uri = URI(url)
    response = Net::HTTP.get(uri)
    weather = JSON.parse(response)
    
    # 温度を少数第1位まで表示するように調整
    weather['main']['temp'] = weather['main']['temp'].round(1) if weather['main'] && weather['main']['temp']
    
    weather
  rescue
    nil # API呼び出しに失敗した場合はnilを返す
  end
end
