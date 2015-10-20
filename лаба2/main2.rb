# подключаем модуль для работы с файлом конфигурации
require 'yaml'

# Путь к файлу конфигурации
PATH = 'config2.yml'

# Грузим данные из файла конфигурации
config = YAML::load(open(PATH))
$general = []

config.each_key do |set_name|
   # Для удобства определяем набор средств защиты
   current_set = config[set_name]
   # # Определяем названия критериев и издержек
   # criteria = current_set['criteria']
   # costs = current_set['costs']

   # Для удобства определяем альтернативы конкретного набора
   alternatives = current_set['alternatives']

   # Определяем первую альтернативу в наборе для использования в качестве эталона
   first_alternative = alternatives.first[1]
   # Объявляем массивы минимальных и максимальных критериев и издержек
   max_criteria = first_alternative['criteria'].clone
   min_criteria = first_alternative['criteria'].clone
   max_costs = first_alternative['costs'].clone
   min_costs = first_alternative['costs'].clone
   # Пройдемся по каждому элементу набора для определения массивов минимальных
   #  и максимальных критериев и издержек
   alternatives.each_key do |alternative_name|
      # Для удобства определяем конкретную альтернативу
      alternative = current_set['alternatives'][alternative_name]

      # Для удобства определяем критерии альтернативы
      alternative_criteria = alternative['criteria']
      # Пройдемся по каждому из критериев альтернативы для нахождения
      #  наименьшего и наибольшего значений
      alternative_criteria.each_index do |criteria_index|
         if alternative_criteria[criteria_index] > max_criteria[criteria_index]
            max_criteria[criteria_index] = alternative_criteria[criteria_index]
         elsif alternative_criteria[criteria_index] < min_criteria[criteria_index]
            min_criteria[criteria_index] = alternative_criteria[criteria_index]
         end
      end

      # Для удобства определяем издержки альтернативы
      alternative_costs = alternative['costs']
      # Пройдемся по каждому из издержек альтернативы для нахождения
      #  наименьшего и наибольшего значений
      alternative_costs.each_index do |costs_index|
         if alternative_costs[costs_index] > max_costs[costs_index]
            max_costs[costs_index] = alternative_costs[costs_index]
         elsif alternative_costs[costs_index] < min_costs[costs_index]
            min_costs[costs_index] = alternative_costs[costs_index]
         end
      end
   end
   set_array = []
   # Пройдемся ещё раз по каждому элементу набора для определения критетиев и издержек
   alternatives.each_key do |alternative_name|
      # Для удобства определяем конкретную альтернативу
      alternative = current_set['alternatives'][alternative_name]

      alternative['sum_criteria'] = 0
      # Для удобства определяем критерии альтернативы
      alternative_criteria = alternative['criteria']
      # Пройдемся по каждому из критериев альтернативы для определения нового значения
      alternative_criteria.each_index do |criteria_index|
         min = min_criteria[criteria_index]
         max = max_criteria[criteria_index]
         if min != max
            alternative_criteria[criteria_index] =
               ( alternative_criteria[criteria_index] - min ).to_f / ( max - min )
            alternative['sum_criteria'] += alternative_criteria[criteria_index]
         else
            alternative_criteria[criteria_index] = 0
         end

      end

      alternative['sum_costs'] = 0
      # Для удобства определяем критерии альтернативы
      alternative_costs = alternative['costs']
      # Пройдемся по каждому из критериев альтернативы для определения нового значения
      alternative_costs.each_index do |costs_index|
         # current_costs = alternative_costs[costs_index]
         min = min_costs[costs_index]
         max = max_costs[costs_index]
         if min != max
            alternative_costs[costs_index] =
               ( alternative_costs[costs_index] - min ).to_f / ( max - min )
            alternative['sum_costs'] += alternative_costs[costs_index]
         else
            alternative_costs[costs_index] = 0
         end
      end

      # Очень плохо, на скорую руку
      alternative['name'] = alternative_name
      set_array << alternative
   end

   $general << set_array
end

# Этапы:
# 0 - каждый set записываем в массив
# 1 - формирование массива со значениями - x
# 2 - как только сформировали конкретный х проходим по каждому из значений и вычисляем общее значение.
# 3 - формируем новый х

# Массив конечных данных
$result = []
# Номер текущего наборы - текущий уровень
$combination = []
def branch (set_number)
   if set_number == $general.length
      w1 = 0
      w2 = 0
      combination_name = ''
      $combination.each_index do |index|
         w1 += $combination[index]['sum_criteria']
         w2 += $combination[index]['sum_costs']
         combination_name += $combination[index]['name']
      end
      combination_object = {
         value: w1.to_f / w2,
         name: combination_name
      }
     $result << combination_object
     $combination.pop
   else
      $general[set_number].each_index do |index|
         $combination[set_number] = $general[set_number][index]
         branch (set_number + 1)
      end
   end
end

branch 0
$result = $result.sort_by { |hsh| hsh[:value] }
$result.reverse!
$general.each do |set|
   set.each do |item_of_set|
      sum_criteria = item_of_set['sum_criteria'].to_s
      sum_costs = item_of_set['sum_costs'].to_s
      name = item_of_set['name']
      puts 'СЗИ ' + name + ' суммарный показатель защищенности:' + sum_criteria + '. Суммарные издержки: ' + sum_costs 
   end
end
puts()
puts 'Результаты:'
1.upto(5) do |number| 
   result = $result[number-1]
   name = result[:name]
   s_number = number.to_s
   value = result[:value]
   s_value = value.to_s
   puts 'Выборка ' + name + ' набрала ' + s_value + ' - ' + s_number + ' место'
end
