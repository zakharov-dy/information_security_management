var lr3 = {
   initBranchNumber: 0,
   combination_set: [],
   combination: [],
   arrayData: [],
   arrayP: [],
   deltaP: 0.05,
   lastP: 1,

   _onLoadFile: function (json) {
      if (json != undefined && json.struct != undefined) {
         this.struct = json.struct;
         this.damage = json.damage;
         this.chartData = json.chartData;
         // формируем массив комбинаций для построения z
         this._branch(this.initBranchNumber);
         // формируем строку для каждого J
         this._formationJ();
         this._formArrayP();
         this._formData();
         // формируем график
         this._createChart();
         console.log(this.j_struct[0]);
         console.log(this.j_struct[1]);
         console.log(this.j_struct[2]);
      }
      else {
         alert('error');
      }
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
      var deltaP = this.deltaP,
         lastP = this.lastP;
      // Формируем массив p-шек
      for (var i = 0; i <= lastP; i+= deltaP) {
         this.arrayP.push(i.toFixed(2));
      }

   },

   _formData: function () {
      this.arrayData = [[],[],[]];
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
      var ctx = $("#myChart").get(0).getContext("2d");
      var myLineChart = new Chart(ctx).Line(data);
   }
};
$(document).ready(function(){
   xhttp = new XMLHttpRequest();
   xhttp.open('GET', 'source/struct3.json', true);
   xhttp.send();
   xhttp.onreadystatechange = function () {
      if (xhttp.readyState == 4 && xhttp.status == 200) {
         json = JSON.parse(xhttp.responseText);
         lr3._onLoadFile(json);
      }
   }
});