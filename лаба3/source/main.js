$(document).ready(function(){
    xhttp = new XMLHttpRequest();
    xhttp.open('GET', 'source/struct.json', true);
    xhttp.send();
    xhttp.onreadystatechange = function () {
        if (xhttp.readyState == 4 && xhttp.status == 200) {
            json = JSON.parse(xhttp.responseText);
            _onLoadFile(json);
        }
    }
});
var initBranchNumber = 0;
var result = [];
var combination = [];

function _onLoadFile(json) {
    if (json != undefined && json.struct != undefined) {
        window.struct = json.struct;
        _branch(initBranchNumber);
    }
    else {
        alert('error');
    }
}

var _branch = function _branch(branchNumber){
     if (branchNumber === window.struct.length) {
        result.push(combination);
     }
     else {
         var struct = window.struct;
         for (var i = 0; i < struct[branchNumber].length; i++) {
             combination[branchNumber] = struct[branchNumber][i];
             _branch(branchNumber + 1);
         }
     }
 };
console.log(result);