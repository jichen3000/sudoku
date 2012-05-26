require 'sinatra'
require 'haml'
require 'json'

require File.join(File.dirname(__FILE__),'sudoku')

get "/sudoku" do
  haml :main, :locals => {:sudoku_size => 9}
end
get "/index" do
  haml :index, :locals => {:hello => "colin"}
end

get "/sudoku/sudokuresult" do
  #params[:fix_values].each {|point,v| p point,v}
  result = NineSquare.new(params[:fix_values]).perform().get_multi_result()[0]
  points = {}
  result.each do |key,value|
    new_key = key.join("_")
    if not params[:fix_values][new_key]
      points[key.join("_")]=value
    end
  end
  points.to_json
end

def helper(group_index, inner_index)
  y, x = group_index.divmod(3)
  inner_y, inner_x = inner_index.divmod(3)
  [x*3+inner_x, y*3+inner_y]
end
