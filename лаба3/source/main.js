/**
 * Created by Дмитрий on 02.11.2015.
 */
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

function _onLoadFile(json) {
    if (json != undefined && json.struct != undefined) {
        window.struct = json.struct;
        _branch(initBranchNumber);
    }
    else {
        alert('Что-то пошло не так');
    }
    //for (var i = 0; i < struct.length; i++) {
    //
    //}
}
