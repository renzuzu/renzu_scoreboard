var admin = false
        var showid = true
        var showadmins = false
        var showvip = false
        var showjobs = false
        function Addplayers(cache,identity) {
            for (const i in cache.whitelistedjobs) {
              $("#jobs").prepend(`<span style="position: relative;float:left;margin-right: 20px;opacity: 1.0;margin-top: 20px;">
              <span class="leaderboard__title--bottom" style="opacity: 1.0;">`+cache.whitelistedjobs[i].fa+` `+cache.whitelistedjobs[i].label+`</span>
              <span class="leaderboard__title--bottom" style="float: right;"><content id="jobcount">`+cache.whitelistedjobs[i].count+`</content></span>
              </span>`);
            }
            for (const i in cache.players) {
              console.log(i,'gago',cache.players[i])
              if (cache.useidentity) {
                cache.players[i].name = ''+cache.players[i].firstname+' '+cache.players[i].lastname+''
              }
              // if (cache.usediscordname) {
              //   cache.players[i].name = ''+cache.players[i].discordname+''
              // }
              ping = '<i class="fad fa-wifi"></i> '+cache.players[i].ping+''
              if (cache.players[i].ping > 300) {
                ping = '<i style="color:red;" class="fad fa-wifi"></i> '+cache.players[i].ping+''
              } else if (cache.players[i].ping > 100) {
                ping = '<i style="color:yellow;" class="fad fa-wifi"></i> '+cache.players[i].ping+''
              }
              var divid = `<span class="leaderboard__name" style="float: left;position: absolute;left: -1.5vw;bottom: 0%;font-weight: 700;font-size: 14px;width: auto;min-width: 55px;background: #0808087d;border-radius: 5px;color: #daebf5;"><i class="fad fa-id-card"></i> `+cache.players[i].id+`</span>`
              if (!showid && !admin) {
                divid = ''
              }
              var admindiv = ''
              if (cache.players[i].admin) {
                admindiv = `<span class="leaderboard__name admin" style="float: left;position: absolute;left: 3vw;font-weight: 700;font-size: 15px;bottom: 8%;color: gold;"><i class="fad fa-crown"></i></span>`
              }
              if (!showadmins) {
                admindiv = ''
              }
              var vipdiv = ''
              if (cache.players[i].vip) {
                vipdiv = `<span class="leaderboard__name vip" style="float: left;position: absolute;left: 30px;font-weight: 700;font-size: 15px;bottom: 22px;color: #d206d2;"><i class="fad fa-star"></i></span>`
              }
              if (!showvip) {
                vipdiv = ''
              }
              var jobdiv = `<span class="leaderboard__name job" style="float: left;position: absolute;left: 30vw;font-weight: 700;font-size: 15px;"><i class="fad fa-user-tie"></i> `+capitalizeFirstLetter(cache.players[i].job)+`</span>`
              if (!showjobs && !admin) {
                jobdiv = ''
              }
              var discdiv = ''
              if (cache.usediscordname) {
                discdiv = '<span class="leaderboard__name discordname" style="float: left;position: absolute;left: 3vw;font-weight: 700;font-size: 1vh;bottom: 0.5vh;"><i class="fab fa-discord"></i> '+cache.players[i].discordname+'</span>'
              }
              //console.log(i,cache[i].name)
              $("#main").prepend(`<article class="leaderboard__profile">
              <img src="`+cache.players[i].image+`" alt="`+cache.players[i].name+`" class="leaderboard__picture">
              <span class="leaderboard__name">`+cache.players[i].name+`</span>
              `+jobdiv+`
              `+discdiv+`
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
        window.addEventListener('message', function (cache) {
          let event = cache.data;
          if (event.type == 'css') {
            if (event.content == 'old') {
              document.getElementById("css_default").disabled = true;
              $('link[href="stylenew.css"]').remove();
              $('head').append('<link rel="stylesheet" type="text/css" href="styleold.css">');
            } else {
              $('head').append('<link rel="stylesheet" type="text/css" href="stylenew.css">');
            }
          }
          if (event.type == 'show') {
            showid = event.content.showid
            showvip = event.content.showvip
            showadmins = event.content.showadmins
            showjobs = event.content.showjobs
            if (event.content.isadmin) {
              admin = true
            }
            if (event.content.myimage !== undefined) {
              $("#myavatar").attr("src", event.content.myimage);
              $("#currentavatar").attr("src", event.content.myimage);
            }
            $("#logo").attr("src", event.content.logo);
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
            document.getElementById("main").innerHTML = '';
            document.getElementById("jobs").innerHTML = '';
          }
          if (data.keyCode == '121') { // Escape key 76 = L (Change the 76 to whatever keycodes you want to hide the carlock ui LINK https://css-tricks.com/snippets/javascript/javascript-keycodes/)
            $.post("https://renzu_scoreboard/close",{},function(datab){});
            document.getElementById("scoreboard").style.display = "none";
            document.getElementById("main").innerHTML = '';
            document.getElementById("jobs").innerHTML = '';
          }
        }
        function imageExists(image_url){

          var http = new XMLHttpRequest();
      
          http.open('HEAD', image_url, false);
          http.send();
      
          return http.status != 404;
      
        }
        document.getElementById("changeavatar").addEventListener("click", function(event){
          console.log($( "form" ).serialize())
            for (const i in $( "form" ).serializeArray()) {
              var url = $( "form" ).serializeArray()
              if (checkURL(url[i].value)) {
                if (imageExists(url[i].value)) {
                  console.log("UPLOAD")
                  $.post("https://renzu_scoreboard/avatarupload",JSON.stringify({url:url[i].value}),function(datab){});
                }
              }
            }
        });
        // Get the modal
      var modal = document.getElementById("myModal");
      
      // Get the button that opens the modal
      var btn = document.getElementById("myBtn");
      
      // Get the <span> element that closes the modal
      var span = document.getElementsByClassName("close")[0];
      
      // When the user clicks the button, open the modal 
      btn.onclick = function() {
        modal.style.display = "block";
      }
      
      // When the user clicks on <span> (x), close the modal
      span.onclick = function() {
        modal.style.display = "none";
      }
      
      // When the user clicks anywhere outside of the modal, close it
      window.onclick = function(event) {
        if (event.target == modal) {
          modal.style.display = "none";
        }
      }
      function checkURL(url) {
        return(url.match(/\.(jpeg|jpg|gif|png)$/) != null);
      }