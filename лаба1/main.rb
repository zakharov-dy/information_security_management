# подключаем модуль для работы с файлом конфигурации
require 'yaml'

# Путь к файлу конфигурации
PATH = 'config.yml'

# Хэши для минимальных и максимальных параметров
min_params = Hash.new 
max_params = Hash.new 

# Хэш для численных значений критериев в относительных единицах
main_params = Hash.new
# Хэш для результатов первого метода
method1 = Hash.new
# Хэш для матрицы ранжирования - хэш отсортированных массивов
matrix = Hash.new
# Хэш для результатов второго метода
method2 = Hash.new

# Грузим данные из файла конфигурации
config = YAML::load(open(PATH))

# Для каждого параметра в цикле вытаскиваем имя параметра и его значение
config['params'].each do |parameter_name, parameter_value|
   # Для каждого параметра создадим отдельный массив
   matrix[parameter_name] = Array.new
   # Вытаскиваем значение объекта по конкретному параметру
   config['objects'].each_key do |object_name|

      # Создадим вложенный хэш с именем параметра, если он ещё не создан
      main_params[object_name] = Hash.new() if main_params[object_name].nil?
      # Создадим переменные с именем параметра, если они ещё не созданы
      method1[object_name] = 0 if method1[object_name].nil?
      method2[object_name] = 0 if method2[object_name].nil?

   	# Для удобства вводим переменную со значением параметра 
   	value = config['objects'][object_name][parameter_name]
      # Пушим элемент в массив
      matrix[parameter_name] << value
   	# Если в хэше минимального параметра нет значения => имеем дело
   	# 	с пустыми хэшами. Тогда записываем в них текущее значение
      if min_params[parameter_name].nil?
      	min_params[parameter_name] = value
      	max_params[parameter_name] = value
      # Иначе хэши не пусты. Тогда записываем значение в тот или иной хэш,
      #  если значение меньше, или больше текущего значения хэша
      else
      	if min_params[parameter_name] > value
      		min_params[parameter_name] = value
      	elsif max_params[parameter_name] < value
      		max_params[parameter_name] = value
      	end
      end
   end

   # Сортируем массив "матрицы ранжирования" в прямом, или обратном порядке
   if parameter_name.eql? 'price'
      matrix[parameter_name].sort!
   else
      matrix[parameter_name].sort!.reverse!
   end
   # Убираем лишние элементы в массиве со значением матрицы ранжирования
   matrix[parameter_name].uniq!
   
   # Теперь у конкретного параметра мы имеем минимальное и максимальное значение
   max = max_params[parameter_name]
   min = min_params[parameter_name]
   # Пройдемся по каждому из объектов для формирования численных значений критериев в относительных единицах
   config['objects'].each_key do |object_name|
      # В зависимости от характера критерия выбираем ту или иную формулу подсчета критерия в относительной единице
      object_params_value = config['objects'][object_name][parameter_name] 
      if !parameter_name.eql? 'price'
         k1 = (( object_params_value - min ).to_f / ( max - min )) * parameter_value
      else
         k1 = (( max - object_params_value ).to_f / ( max - min )) * parameter_value
      end
      
      main_params[object_name][parameter_name] = k1

      # Итоговое значение для первого метода
      if method1[object_name].eql? 0
         method1[object_name] = k1
      else
         method1[object_name] += k1
      end

      # здесь k2 - переменная, равная номеру элемента массива. - вес от 0 до колличества элементов
      k2 = matrix[parameter_name].index(object_params_value)
      # Итоговое значение для второго метода
      if method2[object_name].eql? 0
         method2[object_name] = k2
      else
         method2[object_name] += k2
      end
      
   end
end
puts main_params
# Вывод результатов и определение наилучших объектов
puts method1
puts method2