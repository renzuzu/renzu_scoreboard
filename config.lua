config = {}
config.Mysql = 'mysql-async' -- "ghmattisql", "msyql-async"
config.UseIdentityname = true -- will not use steamname and it will use a firstname lastname from users table
config.Showid = true -- if false only admins can see the id
config.ShowAdmins = true -- if true admin badge will show near the avatar
config.ShowJobs = true -- show player jobs in scoreboard
config.adminfa = '<i class="fad fa-crown"></i>' -- font awsome icon to show
config.vipfa = '<i class="fad fa-star"></i>' -- fontawsome, change this whatever icon you want from fontawsome
config.ShowVips = true -- if true the player with users.vip will show a vip badge
config.whitelistedjobs = {
    [1] = {name = 'police', fa = '<i class="fad fa-siren-on"></i>'},
    [2] = {name = 'mechanic', fa = '<i class="fad fa-car-mechanic"></i>'},
    [3] = {name = 'ambulance', fa = '<i class="fas fa-user-md"></i>'},
}