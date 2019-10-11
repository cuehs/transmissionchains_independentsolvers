/**
 * Created by Yahosseini on 20.12.2016.
 */
"use strict";

var landscapes = [];
var positionSave = [];
var payoffSave = [];
$.ajax({
    type: 'GET',
    url: 'landscapes.json',
    async:false,
    cache:false,
    success: function(data) {
        console.log(data);
        landscapes=data ;
    }, error: function (data) {
        alert('loading landscapes failed');
    }
});


function lightBulbFunction(x){
    ws.send('ping');
    console.log(totalPoints);
    if((step) === stepPerLevel ){
        $('#message').html("<h2>Du hast keine Züge mehr!</h2>");
        $('#message').html($('#message').html()+ ' <br> Du hast '+ landscapes[landscapeId].body[position.join("")][0] + ' Punkte erhalten. <br> Starte das nächste Level ');
        positionSave.push("e,"+ position.join("")+ ",NA");
        payoffSave.push("e,"+landscapes[landscapeId].body[position.join("")][0]+ ",NA");
        totalPoints = totalPoints + landscapes[landscapeId].body[position.join("")][0];
        step++;
        return;
    }
    if(step > stepPerLevel ){
        $('#message').html("<h2>Du hast keine Züge mehr!</h2>");
        $('#message').html($('#message').html()+ ' <br> Du hast '+ landscapes[landscapeId].body[position.join("")][0] + ' Punkte erhalten. <br> Starte das nächste Level ');
        return;
    }
    if(mask[x]){
        previousPosition = position.slice();
        var oldPayoff = landscapes[landscapeId].body[previousPosition.join("")][0];
        position[x] = (position[x] +1) % 2;
        var payoff = landscapes[landscapeId].body[position.join("")][0];
        if(position[x] == 0){
            $('#message').html("Du hast eine Glühbirne ausgeschaltet .");
        }

        if(position[x] == 1){
            $('#message').html("Du hast eine Glühbirne eingeschaltet.");
        }

        if(oldPayoff > payoff){
            $('#message').html($('#message').html()+ " <br> Du würdest jetzt <b>" + payoff + "</b> Punkte erhalten. <br> <font color='red'>Weniger als vorher </font> "  );
        }
        else if(oldPayoff < payoff){
            $('#message').html($('#message').html()+ " <br> Du würdest jetzt <b>" + payoff + "</b> Punkte erhalten. <br> <font color='green'> Mehr als vorher </font> "  );
        }
        else{
            $('#message').html($('#message').html()+ " <br> Du würdest jetzt <b>" + payoff + "</b> Punkte erhalten. <br> <font color='grey'> Keine Veränderung </font> "  );
        }

        step = step+1;
        positionSave.push("n,"+ position.join("")+ ",NA");
        payoffSave.push("n,"+ landscapes[landscapeId].body[position.join("")][0]+ ",NA");
        update();
    }else{
        $('#message').show();
        $('#message').html("Du kannst hier nichts verändern!");
    }
}

function update() {
    var span = $('#position_viz');
    var buttons = span.children();
    for (var i = 0; i < buttons.length; i++) {
        if(!mask[i] & position[i] === 0){
            buttons[i].innerHTML = '<img src="img/off_not.png" />';
        } else if(!mask[i] & position[i] ===1){
            buttons[i].innerHTML = '<img src="img/on_not.png" />';
        } else if(mask[i] & position[i]=== 0) {
            buttons[i].innerHTML = '<img src="img/off.png" />';
        } else if(mask[i] & position[i] === 1){
            buttons[i].innerHTML = '<img src="img/on.png" />';
        }
    }
    updateSidebar();
}
function revert() {
    if(step > 0){
  position = previousPosition.slice();
  var payoff = landscapes[landscapeId].body[position.join("")][0];
  positionSave.push("b,"+position.join("")+ ",NA");
  payoffSave.push("b,"+landscapes[landscapeId].body[position.join("")][0]+ ",NA");

  $('#message').html("Du hast deine letzte Änderung zurückgenommen");
  $('#message').html($('#message').html()+ " <br> Du würdest jetzt <b>" + payoff + "</b> Punkte erhalten. <br> <font color='grey'>&ensp;</font> "  );
  update();
    }
}
function skipRestOfLevel(){
    if(step <stepPerLevel ){
    step = stepPerLevel;
    }
    lightBulbFunction(null);
    startNewLevel();
}

function startNewLevel() {
    if((positionSave.length) > 0 & (payoffSave.length > 0)){
        for( var i = 0; i < payoffSave.length; i++) {
            ws.send("position:" + level + ":" + i+","+positionSave[i]);
            ws.send("payoff:" + level + ":" + i+ ","+payoffSave[i]);
        }
    positionSave.splice(0,positionSave.length)
    payoffSave.splice(0,payoffSave.length)
    }
    if(position.length > 0){
        ws.send("endPosition:"+level+":"+position);
    }

    if((level+1) >= levelTotal){
        endGame();
        return;
    }
    level++;
    landscapeId = state[level].landscapeId;
    step = 0;
    var manipulate =  (state[level].isLowStrength)?3:6;
    stepPerLevel = manipulate * 2;
    position = (state[level].isSequential)?state[level].sequentialPosition:state[level].starting;

    mask = new Array(10).fill(false);
    for( var i = 0;i<mask.length; i++){
        if(i < manipulate){
            mask[i] = true;
        }
    }
    shuffleArray(mask);

    update();
    positionSave.push("s,"+ position.join("")+ "," + mask.join(""));
    payoffSave.push("s,"+ landscapes[landscapeId].body[position.join("")][0] + "," + mask.join(""));

    $('#message').html("Los geht's!");
    $('#message').html($('#message').html()+ "<br>In diesem Level hast du  <b>" + stepPerLevel + "</b> Züge. <br>");
    $('#message').html($('#message').html()+ "Du würdest jetzt <b>" + landscapes[landscapeId].body[position.join("")][0] + "</b> Punkte erhalten.");
}

function startGame(){
    totalPoints = 0;
    level--;
    startNewLevel();
    $('#game').show();
}
function endGame() {
    $('#game').html("Das Experiment ist beendet. <br> Du hast <b>" + totalPoints + "</b> Punkte erreicht!<br>" + "Dein Bonus ist: " + Math.round(totalPoints*.017) + "Cents."   )
    ws.send("endExperiment");
}