# подключаем модуль для работы с файлом конфигурации
require 'yaml'

# Путь к файлу конфигурации
PATH = 'config2.yml'

# Грузим данные из файла конфигурации
config = YAML::load(open(PATH))
$general = []
count = -1
config.each_key do |set_name|
   # Для удобства определяем набор средств защиты
   current_set = config[set_name]
   # Определяем названия критериев и издержек
   criteria = current_set['criteria']
   costs = current_set['costs']

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
         alternative_criteria[criteria_index] =
            ( alternative_criteria[criteria_index] - min ).to_f / ( max - min )
         alternative['sum_criteria'] += alternative_criteria[criteria_index]
      end

      alternative['sum_costs'] = 0
      # Для удобства определяем критерии альтернативы
      alternative_costs = alternative['costs']
      # Пройдемся по каждому из критериев альтернативы для определения нового значения
      alternative_costs.each_index do |costs_index|
         # current_costs = alternative_costs[costs_index]
         min = min_costs[costs_index]
         max = max_costs[costs_index]
         alternative_costs[costs_index] =
            ( alternative_costs[costs_index] - min ).to_f / ( max - min )
         alternative['sum_costs'] += alternative_costs[costs_index]
      end

   end

   $general << current_set
end

# Этапы:
# 0 - каждый set записываем в массив
# 1 - формирование массива со значениями - x
# 2 - как только сформировали конкретный х проходим по каждому из значений и вычисляем общее значение.
# 3 - формируем новый х

# # Массив конечных данных
# result = []
# # Номер текущего наборы - текущий уровень
# set_number = 0
# def branch (combination)
#    if set_number == general.length - 1
#       w1 = 0
#       w2 = 0
#       combination.each_index do |index|
#          w1 += combination[index]['sum_criteria']
#          w2 += combination[index]['sum_costs']
#       end
#       value = w1.to_f / w2
#       result << value
#       combination = []
#    else
#       set_number += 1
#       general[set_number].each_index do |index|
#          combination << general[set_number][index]
#          branch combination
#       end
#    end
# end
# a = []
# branch a # :-D

# # Массив конечных данных
# $result = []
# # Номер текущего наборы - текущий уровень
# $set_number = -1
# def branch (combination)
#    if combination.length == $general.length
#       w1 = 0
#       w2 = 0
#       combination.each_index do |index|
#          w1 += combination[index]['sum_criteria']
#          w2 += combination[index]['sum_costs']
#       end
#       value = w1.to_f / w2
#      $result << value
#    else
#       $set_number += 1
#       $general[$set_number].each_index do |index|
#          combination << $general[$set_number][index]
#          branch combination
#       end
#    end
# end
# a = []
# branch a # :-D
# puts result