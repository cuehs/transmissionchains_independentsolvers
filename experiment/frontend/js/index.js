"use strict";

//var ws = new WebSocket("ws://127.0.0.1:8080/search/echo");
var ws = new WebSocket("ws://35.246.207.27:80/search/echo");
var state;
var step;
var stepPerLevel ;
var level = 0;
var position = [];
var previousPosition = [];
var mask = [];
var totalPoints = 0;
var landscapeId = null;
var tutstate = 0;
var levelTotal = 128;

$('#game').hide();
$('#sidebar').hide();
function trainingButton() {

    switch (tutstate) {
        case 0:
            if (($('input[name=gender]:checked').val() != null) && ($('#age')[0].checkValidity())) {
                ws.send("participant:" + $('input[name=gender]:checked').val() + "," + $('#age').val());
                $('#textfield').html(text.general0.text);
                tutstate++;
                ws.send('ping');
            }
            break;
        case 1:

            ws.send('ping');
            $('#textfield').html(text.general1.text);
            tutstate++;
            break;
        case 2:
            ws.send('ping');
            $('#textfield').html(text.general2.text);
            tutstate++;
            break;
        case 3:
            ws.send('ping');
            $('#textfield').html(text.general3.text);
            tutstate++;
            break;
        case 4:
            ws.send('ping');
            $('#textfield').html(text.general4.text);
            $('#sidebar').show();
            tutstate++;
            break;
        case 5:
            ws.send('ping');
            $('#textfield').html(text.general5.text);
            tutstate++;
            break;
        case 6:
            ws.send('ping');
            $('#textfield').html(text.general6.text);
            tutstate++;
            break;
        case 7:
            ws.send('state');
            ws.send('ping');
            $('#textfield').html(text.general7.text);
            tutstate++;
            break;
        case 8:
            ws.send('ping');
            $('#textfield').html(text.general8.text);
            tutstate++;
            break;
        case 9:
            ws.send('ping');
            tutstate++;

            $('#textbar').hide();
            startGame();
            $('#game').show();
            $('#sidebar').show();
            break;
    }
}

ws.onmessage = function (evt) {
    console.log(JSON.parse(evt.data));
    var msg = JSON.parse(evt.data);
    switch (msg.id) {
        case "State":
            state =  msg.landscapes;
            console.log(state);
            break;
    }
};

ws.onclose = function () {
    alert("Closed!");
};
ws.onerror = function (err) {
    alert("Error: " + err);
};

function shuffleArray(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    // While there remain elements to shuffle...
    while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }

    return array;
}

function getRandomIntInclusive(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function updateSidebar(){
    $('#currentPoint').html(landscapes[landscapeId].body[position.join("")][0]);
    $('#totalPoint').html(totalPoints);
    $('#step').html(stepPerLevel - step);
    $('#stepTotal').html(stepPerLevel);
    $('#level').html(level+1);
}

