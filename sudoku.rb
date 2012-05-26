
module SodukuHelper
  def get_arr_9
    [1,2,3,4,5,6,7,8,9]
  end
  def get_arr_9_9
    get_arr_9.map {get_arr_9}
  end
  def be_subed_arr_9(arr)
    get_arr_9 - arr
  end
  def deep_copy(object)
    Marshal.load(Marshal.dump(object))
  end
  def get_same_group_index_arr(origin_index)
    base_index = origin_index/3 *3
    [0,1,2].map {|x| x+base_index}
  end
  def compute_group_index(x_index,y_index)
    x_index/3*3+y_index/3
  end
  def exist_value?(value)
    value > 0 and value < 10
  end
  def computer_exlude_x_points(possible_value, x_index, y_index, unshow_values)
    x_index_arr = get_same_group_index_arr(x_index)
    x_index_arr.delete(x_index)
    x_index_arr.delete_if do |index|
      unshow_values[index].include?(possible_value)
    end
    y_index_arr = get_same_group_index_arr(y_index)
    x_index_arr.product(y_index_arr)
  end
  def computer_exlude_y_points(possible_value, x_index, y_index,  unshow_values)
    y_index_arr = get_same_group_index_arr(y_index)
    y_index_arr.delete(y_index)
    y_index_arr.delete_if do |index|
      unshow_values[index].include?(possible_value)
    end
    x_index_arr = get_same_group_index_arr(x_index)
    x_index_arr.product(y_index_arr)
  end
  def show_result_map(result_map)
    9.times do |row_index|
      9.times do |col_index|
        value = result_map[[row_index,col_index]]
        value ||= 0
        printf(" #{value},")
      end
      puts ""
    end
  end
end

class NineSquare
  include SodukuHelper
  attr :empty_points_arr
  @@total_answer_count = 0
  @@guess_count = 0
  @@total_answer_iteration_count = 0
  def initialize(start_arr)
    @answer_count=0
    @answer_iteration_count=0
    @unshow_values_by_x_arr = get_arr_9_9
    @unshow_values_by_y_arr = get_arr_9_9
    @unshow_values_by_group_arr = get_arr_9_9
    @result_map = {}
    @empty_points_arr = []
    @group_null_point_arr = get_arr_9.map {[]}
    if start_arr.kind_of?(Array)
      start_arr.each_with_index do |sub_arr,y_index|
        sub_arr.each_with_index do |value,x_index|
          value = value.to_i
          group_index = compute_group_index(x_index,y_index)
          if exist_value?(value)
            set_value(value, x_index, y_index, group_index)
          else
            @empty_points_arr << [x_index,y_index,group_index]
            @group_null_point_arr[group_index] << [x_index,y_index]
          end
        end    
      end
    elsif start_arr.kind_of?(Hash)
      9.times do |x_index|
        9.times do |y_index|
          value = start_arr["#{x_index}_#{y_index}"]
          value = value.to_i
          group_index = compute_group_index(x_index,y_index)
          if exist_value?(value)
            set_value(value, x_index, y_index, group_index)
          else
            @empty_points_arr << [x_index,y_index,group_index]
            @group_null_point_arr[group_index] << [x_index,y_index]
          end
        end
      end
    end
  end
  def perform
    answer_flag, guess_point_map, result_map = answer()
    if answer_flag == 'logic error'
      puts "#{answer_flag} : #{result_map}"
    elsif answer_flag == 'need guess'
      puts "#{answer_flag} : #{guess_point_map}"
      puts "@answer_iteration_count:#{@answer_iteration_count}"
      puts "@answer_count:#{@answer_count}"
      puts "@empty_points_arr:#{@empty_points_arr}"
      @guessed_result_arr = guess(guess_point_map)
    elsif answer_flag=='answered'
      puts "#{answer_flag}"
      @guessed_result_arr =[result_map]
    end
    puts "@answer_count:#{@answer_count}"
    puts "@answer_iteration_count:#{@answer_iteration_count}"
    puts "@@guess_count:#{@@guess_count}"
    puts "@@total_answer_count:#{@@total_answer_count}"
    puts "@@total_answer_iteration_count:#{@@total_answer_iteration_count}"


    self
  end
  def get_multi_result
    @guessed_result_arr
  end
  def show_all()
    @guessed_result_arr.each_with_index do |result_map,index|
      puts "result no #{index}:"
      show_result_map(result_map)
    end
    self
  end  
  def set_value(value, x_index, y_index, group_index)
    @result_map[[x_index,y_index]]=value
    @unshow_values_by_x_arr[x_index].delete(value)
    @unshow_values_by_y_arr[y_index].delete(value)
    @unshow_values_by_group_arr[group_index].delete(value)
    @group_null_point_arr[group_index].delete([x_index,y_index])
    value
  end
  def add_answer_value(value, x_index, y_index, group_index, method_name)
    puts "NO:#{@answer_count} value: #{value} has added at (#{x_index},#{y_index}) "+
        "by #{method_name} in #{@answer_iteration_count+1} iteration."
    @answer_count += 1
    @@total_answer_count += 1
    set_value(value, x_index, y_index, group_index)
  end
  def answer()
    del_arr = []
    method_name = ""
    guess_point_map = {:size => 10}
    @empty_points_arr.each do |x_index,y_index,group_index|
      value = nil
      possible_values = get_possible_values(x_index,y_index,group_index)
      if possible_values.size == 1
        value = possible_values.first
        method_name = 'get_possible_values'
      elsif possible_values.size > 1
        if guess_point_map[:size] > possible_values.size
          guess_point_map[:size] = possible_values.size
          guess_point_map[:index] = [x_index,y_index,group_index]
          guess_point_map[:possible_value] = possible_values
        end
        subset_values = exlude_by_other_row_col(possible_values,x_index,y_index,group_index)
        if subset_values.size == 1
          value = subset_values.first
          method_name = 'exlude_by_other_row_col'
        elsif subset_values.size > 1
          return ['logic error', nil, 'Find two or more value by exluding!']
        end
      else
        return ['logic error', nil, 'Find possible zero numble of value!']
      end
      if value
        add_answer_value(value, x_index, y_index, group_index, method_name)
        del_arr << [x_index,y_index,group_index]
      end
    end
    @answer_iteration_count += 1
    @@total_answer_iteration_count += 1
    if del_arr.size == 0
      return ['need guess', guess_point_map, @result_map]
    end
    @empty_points_arr -= del_arr
    if @empty_points_arr.size > 0
      return answer()
    else
      return ['answered', nil, @result_map]
    end
  end
  def guess(guess_point_map)
    @@guess_count += 1
    guessed_result_arr = []
    x_index, y_index, group_index = guess_point_map[:index]
    guess_point_map[:possible_value].each do |possible_value|
      guess_object = deep_copy(self)
      guess_object.add_answer_value(possible_value, x_index, y_index, group_index, 'guess')
      guess_object.empty_points_arr.delete([x_index, y_index, group_index])
      answer_flag, next_guess_point_map, next_result_map = guess_object.answer()
      if answer_flag == 'logic error'
        puts "ksdf"
        puts "#{answer_flag} : #{next_result_map}"
      elsif answer_flag == 'need guess'
        puts "#{answer_flag} : #{guess_point_map}"
        guessed_result_arr += guess_object.guess(next_guess_point_map)
      elsif answer_flag=='answered'
        puts "#{answer_flag}"
        
        guessed_result_arr << next_result_map
      end
    end
    guessed_result_arr
  end
  
  def get_possible_values(x_index,y_index,group_index)
    @unshow_values_by_x_arr[x_index] & @unshow_values_by_y_arr[y_index] & 
      @unshow_values_by_group_arr[group_index]
  end
  def exlude_by_other_row_col(possible_values,x_index,y_index,group_index)
    result_values = []
    possible_values.each do |possible_value|
      current_group_null_points = @group_null_point_arr[group_index]
      exlude_row_points = computer_exlude_x_points(possible_value, x_index, y_index, @unshow_values_by_x_arr)
      exlude_col_points = computer_exlude_y_points(possible_value, x_index, y_index, @unshow_values_by_y_arr)
      remain_points = current_group_null_points - 
          exlude_row_points - exlude_col_points
      if remain_points.size == 1
        result_values << possible_value
      end
    end
    result_values
  end
end

if $PROGRAM_NAME == __FILE__
  start_arr = [
    %w(9 0 0 0 0 0 0 0 5),
    %w(0 4 0 3 0 0 0 2 0),
    %w(0 0 8 0 0 0 1 0 0),
    %w(0 7 0 6 0 3 0 0 0),
    %w(0 0 0 0 8 0 0 0 0),
    %w(0 0 0 7 0 9 0 6 0),
    %w(0 0 1 0 0 0 9 0 0),
    %w(0 3 0 0 0 6 0 4 0),
    %w(5 0 0 0 0 0 0 0 8)
  ]  
  #start_arr = [
  #  %w(0 0 0 0 9 8 0 2 0),
  #  %w(0 0 0 2 0 0 1 0 4),
  #  %w(0 0 0 0 0 6 5 0 0),
  #  %w(6 0 0 0 4 0 0 9 0),
  #  %w(0 0 0 8 0 3 6 0 0),
  #  %w(4 0 0 0 0 0 0 0 0),
  #  %w(7 0 9 3 2 0 0 0 5),
  #  %w(0 0 1 0 0 7 0 0 0),
  #  %w(0 2 0 0 0 0 7 0 0)
  #]  

  NineSquare.new(start_arr).perform().show_all()
  p "ok"
end