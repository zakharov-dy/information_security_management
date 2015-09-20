# подключаем модуль для работы с файлом конфигурации
require 'yaml'

# Путь к файлу конфигурации
PATH = 'config2.yml'

# Грузим данные из файла конфигурации
config = YAML::load(open(PATH))

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

   puts current_set
end