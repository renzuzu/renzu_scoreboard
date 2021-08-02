var admin = false
        var showid = true
        var showadmins = false
        var showvip = false
        var showjobs = false
        function Addplayers(table,identity) {
            for (const i in table.whitelistedjobs) {
              $("#jobs").prepend(`<span style="position: relative;float:left;margin-right: 20px;opacity: 1.0;margin-top: 20px;">
              <span class="leaderboard__title--bottom" style="opacity: 1.0;">`+table.whitelistedjobs[i].fa+` `+table.whitelistedjobs[i].name+`</span>
              <span class="leaderboard__title--bottom" style="float: right;"><content id="jobcount">`+table.whitelistedjobs[i].count+`</content></span>
              </span>`);
            }
            for (const i in table.players) {
              if (table.useidentity) {
                table.players[i].name = ''+table.players[i].firstname+' '+table.players[i].lastname+''
              }
              ping = '<i class="fad fa-wifi"></i> '+table.players[i].ping+''
              if (table.players[i].ping > 300) {
                ping = '<i style="color:red;" class="fad fa-wifi"></i> '+table.players[i].ping+''
              } else if (table.players[i].ping > 100) {
                ping = '<i style="color:yellow;" class="fad fa-wifi"></i> '+table.players[i].ping+''
              }
              var divid = `<span class="leaderboard__name" style="float: left;position: absolute;left: -1.5vw;bottom: 0%;font-weight: 700;font-size: 14px;width: auto;min-width: 55px;background: #0808087d;border-radius: 5px;color: #daebf5;"><i class="fad fa-id-card"></i> `+table.players[i].id+`</span>`
              if (!showid && !admin) {
                divid = ''
              }
              var admindiv = ''
              if (table.players[i].admin) {
                admindiv = `<span class="leaderboard__name" style="float: left;position: absolute;left: 3vw;font-weight: 700;font-size: 15px;bottom: 8%;color: gold;"><i class="fad fa-crown"></i></span>`
              }
              if (!showadmins) {
                admindiv = ''
              }
              var vipdiv = ''
              if (table.players[i].vip) {
                vipdiv = `<span class="leaderboard__name" style="float: left;position: absolute;left: 5vw;font-weight: 700;font-size: 15px;bottom: 8%;color: #d206d2;"><i class="fad fa-star"></span>`
              }
              if (!showvip) {
                vipdiv = ''
              }
              var jobdiv = `<span class="leaderboard__name" style="float: left;position: absolute;left: 30vw;font-weight: 700;font-size: 15px;"><i class="fad fa-user-tie"></i> `+capitalizeFirstLetter(table.players[i].job)+`</span>`
              if (!showjobs) {
                jobdiv = ''
              }
              //console.log(i,table[i].name)
              $("#main").prepend(`<article class="leaderboard__profile">
              <img src="`+table.players[i].image+`" alt="`+table.players[i].name+`" class="leaderboard__picture">
              <span class="leaderboard__name">`+table.players[i].name+`</span>
              `+jobdiv+`
              `+divid+`
              `+admindiv+`
              `+vipdiv+`
              <span class="leaderboard__value">`+ping+`<span>ms</span></span>
              </article>`);
            }

        }
        function capitalizeFirstLetter(string) {
          return string.charAt(0).toUpperCase() + string.slice(1);
        }
        window.addEventListener('message', function (table) {
          let event = table.data;
          if (event.type == 'show') {
            showid = event.content.showid
            showvip = event.content.showvip
            showadmins = event.content.showadmins
            showjobs = event.content.showjobs
            if (event.content.isadmin) {
              admin = true
            }
            Addplayers(event.content)
            document.getElementById("scoreboard").style.display = "block";
            document.getElementById("count").innerHTML = event.content.count;
            document.getElementById("max").innerHTML = event.content.max;
          }
          if (event.type == 'close') {
            document.getElementById("main").innerHTML = '';
            document.getElementById("jobs").innerHTML = '';
            document.getElementById("scoreboard").style.display = "none";
          }
        });
        document.onkeyup = function (data) {
          if (data.keyCode == '27') { // Escape key 76 = L (Change the 76 to whatever keycodes you want to hide the carlock ui LINK https://css-tricks.com/snippets/javascript/javascript-keycodes/)
            $.post("https://renzu_scoreboard/close",{},function(datab){});
            document.getElementById("scoreboard").style.display = "none";
          }
          if (data.keyCode == '121') { // Escape key 76 = L (Change the 76 to whatever keycodes you want to hide the carlock ui LINK https://css-tricks.com/snippets/javascript/javascript-keycodes/)
            $.post("https://renzu_scoreboard/close",{},function(datab){});
            document.getElementById("scoreboard").style.display = "none";
          }
        }