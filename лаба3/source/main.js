var lr3 = {
   initBranchNumber: 0,
   combination_set: [],
   combination: [],

   _onLoadFile: function (json) {
      if (json != undefined && json.struct != undefined) {
         this.struct = json.struct;
         this.damage = json.damage
         // формируем массив комбинаций для построения z
         this._branch(this.initBranchNumber);
         // формируем строку для каждого J
         this._formationJ()
      }
      else {
         alert('error');
      }
   },

   _branch: function _branch (branchNumber) {
      var struct = lr3.struct,
         combination = lr3.combination
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
            for (var key in combination_set[j][i]) {
               if (combination_set[j][i].hasOwnProperty(key)) {
                  // j_struct[i] += combination_set[j][i][key]
                  j_struct[i] += '(' +  combination_set[j][i][key] + ')' + "*" + lr3.damage[key] + ' '
               }
            }
         }
      }
      console.log(j_struct);
   }

};

$(document).ready(function(){
   xhttp = new XMLHttpRequest();
   xhttp.open('GET', 'source/struct.json', true);
   xhttp.send();
   xhttp.onreadystatechange = function () {
      if (xhttp.readyState == 4 && xhttp.status == 200) {
         json = JSON.parse(xhttp.responseText);
         lr3._onLoadFile(json);
      }
   }
});



