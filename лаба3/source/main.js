var lr3 = {
   structs: [
      [
         [
            {"v1": "p"},
            {"v3": "1-p"}
         ],
         [
            {"v1": "(1-p)/2"},
            {"v2": "(1-p)/2"},
            {"v4": "p"}
         ]
      ],
      [
         [
            {"v1": "p"},
            {"v3": "1-p"}
         ],
         [
            {"v1": "1/3"},
            {"v2": "1/3"},
            {"v3": "1/3"}
         ],
         [
            {"v1": "1-p"},
            {"v3": "p"}
         ]
      ],
      [
         [
            {"v1": "p"},
            {"v3": "1-p"}
         ],
         [
            {"v1": "p/2"},
            {"v2": "1-p"},
            {"v3": "p/2"}
         ],
         [
            {"v1": "(1-p)/2"},
            {"v2": "(1-p)/2"},
            {"v4": "p"}
         ]
      ]
   ],

   chartData: {
      label: ["блокирование ТД", "DOS-атака на атакующую станцию", "Отсутствие реагирования"],
      fillColor: ["rgba(220,220,220,0.2)", "rgba(151,187,205,0.2)", "rgba(70,191,189,0.2)"],
      strokeColor: ["rgba(220,220,220,1)","rgba(151,187,205,1)","rgba(70,191,189,0.2)" ],
      pointColor: ["rgba(220,220,220,1)",  "rgba(151,187,205,1)",  "rgba(70,191,189,0.2)"],
      pointHighlightStroke: ["rgba(220,220,220,1)", "rgba(151,187,205,1)", "rgba(70,191,189,0.2)"]
   },

   _generateChart: function(index, damage, deltaP) {
      this.initBranchNumber = 0;
         this.combination_set = [];
         this.combination = [];
         this.arrayData = [];
         this.lastP = 1;
      this.struct = this.structs[index-1];
      this.damage = damage;
      this.deltaP = deltaP;
      console.log(this.struct);
      console.log(this.damage);
      // формируем массив комбинаций для построения z
      this._branch(this.initBranchNumber);
      // формируем строку для каждого J
      this._formationJ();
      this._formArrayP();
      this._formData();
      // формируем график
      this._createChart();
   },

   _branch: function _branch (branchNumber) {
      var struct = lr3.struct,
         combination = lr3.combination;
      if (branchNumber === struct.length) {
         //Подумать, как написать более правильно
         var clone = [];
         for (var key in combination) {
            clone[key] = combination[key];
         }
         lr3.combination_set.push(clone);
      }
      else {
         for (var i = 0; i < struct[branchNumber].length; i++) {
            combination[branchNumber] = struct[branchNumber][i];
            _branch(branchNumber + 1);
         }
      }
   },

   _formationJ: function () {
      var combination_set = this.combination_set;
      this.j_struct = new Array(combination_set[0].length);
      j_struct = this.j_struct;
      for (var i = 0; i < j_struct.length; i++) {
         j_struct[i] = '';
         for (var j = 0; j < combination_set.length; j++) {
            // формируем z
            for (var k = 0; k < combination_set[j].length; k++) {
               for (var key in combination_set[j][k]) {
                  if (combination_set[j][k].hasOwnProperty(key)) {
                     j_struct[i] += '(' +  combination_set[j][k][key] + ')'+ '*';
                  }
               }
            }
            // Умножаем z на С(Vi)
            for (var key2 in combination_set[j][i]) {
               j_struct[i] += lr3.damage[key2] + ' ';
            }
         }
         // Формируем j_struct
         j_struct[i] = j_struct[i].split(' ').join('+').slice(0, -1);
      }
   },

   _formArrayP: function () {
      this.arrayP = [];
      var deltaP = this.deltaP,
         lastP = this.lastP;
      // Формируем массив p-шек
      for (var i = 0; i <= lastP; i+= deltaP) {
         this.arrayP.push(i.toFixed(2));
      }

   },

   _formData: function () {
      this.arrayData = [];
      for (var k = 0; k <= this.struct.length; k++) {
         this.arrayData.push([]);
      }
      for ( var i = 0; i < this.j_struct.length; i++ ) {
         for ( var j = 0; j < this.arrayP.length; j++ ) {
            var p = this.arrayP[j];
            this.arrayData[i].push((eval(this.j_struct[i])).toFixed(2));
         }
      }
   },

   _createChart: function() {
      var chartData = this.chartData,
         arrayData = this.arrayData,
         yData = [];
      for (var i = 0; i < this.j_struct.length; i++) {
         var chartDataElement = {
            label: chartData.label[i],
            fillColor: chartData.fillColor[i],
            strokeColor: chartData.strokeColor[i],
            pointColor: chartData.pointColor[i],
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: chartData.pointHighlightStroke[i],
            data: arrayData[i]
         };
         yData.push(chartDataElement);
      }

      var data = {
         labels: this.arrayP,
         datasets: yData
      };

      var options = {
         bezierCurve : false
      };
      updateChart(data, options);
      //$('#myChart').remove();
      //$('#graph-container').append('<canvas id="myChart" style="width: 100%; height: 100%"></canvas>');
      //canvas = document.querySelector('#myChart');

      //if (typeof myChart != 'undefined') {
      //   myChart.destroy();
      //   ctx = {};
      //}
      //
   }
};

function updateChart(data, options) {
   if (typeof myChart.datasets != 'undefined') {
      myChart.destroy();
      ctx = document.querySelector('canvas').getContext('2d');
      myChart = new Chart(ctx).Line(data, options);
   }
   else{
      ctx = document.querySelector('canvas').getContext('2d');
      myChart = new Chart(ctx).Line(data, options);
   }
}

$(document).ready(function(){
   var generateDamage = function(count) {
      var damage = {};
      for (var i = 1; i < count+1; i++) {
         var path = '.damage.active > .' + i + 'damage';
         var value = +$(path).val();
         if (typeof value === 'number' && value >= 0 ) {
            var key = 'v' + i;
            damage[key] = value;
         }
         else {
            return false;
         }
      }
      return damage;
   };

   $('#chartNumber').change(function() {
      var value = $(this).val();
      if (value == '2' ) {
         $('.damage4').removeClass('active');
         $('.damage4').addClass('passive');
         $('.damage3').removeClass('passive');
         $('.damage3').addClass('active');
      }
      else {
         $('.damage3').removeClass('active');
         $('.damage3').addClass('passive');
         $('.damage4').removeClass('passive');
         $('.damage4').addClass('active');
      }


   });
   $('#generateChart').click(function() {
      var damage,
         index = +$('#chartNumber').val(),
         deltaP = +$('#deltaP').val();
      if (typeof deltaP !== 'number' || deltaP <= 0 || deltaP > 1) {
         alert('Ошибка в указании шага графика. Шаг должен быть числом от 0 до 1');
         return;
      }
      switch (index) {
         case 1:
            damage = generateDamage(4);
            if (!damage) {
               alert('Ошибка в указании ущерба. Ущерб должен быть положительным числом. Например 0.5');
               return;
            }
            break;
         case 2:
            damage = generateDamage(3);
            if (!damage) {
               alert('Ошибка в указании ущерба. Ущерб должен быть положительным числом. Например 0.5');
               return;
            }
            break;
         case 3:
            damage = generateDamage(4);
            if (!damage) {
               alert('Ошибка в указании ущерба. Ущерб должен быть положительным числом. Например 0.5');
               return;
            }
            break;
      }
      lr3._generateChart(index, damage, deltaP)
   });
});