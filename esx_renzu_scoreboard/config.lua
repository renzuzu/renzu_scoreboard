config = {}
config.Mysql = 'mysql-async' -- "ghmattisql", "msyql-async"
config.UseIdentityname = true -- will not use steamname and it will use a firstname lastname from users table
config.Showid = true -- if false only admins can see the id
config.ShowAdmins = true -- if true admin badge will show near the avatar
config.ShowJobs = true -- show player jobs in scoreboard , if false only admins can see the jobs
config.adminfa = '<i class="fad fa-crown"></i>' -- font awsome icon to show
config.vipfa = '<i class="fad fa-star"></i>' -- fontawsome, change this whatever icon you want from fontawsome
config.ShowVips = true -- if true the player with users.vip will show a vip badge
config.whitelistedjobs = {
    [1] = {name = 'police', fa = '<i class="fad fa-siren-on"></i>', label = 'Police'},
    [2] = {name = 'mechanic', fa = '<i class="fad fa-car-mechanic"></i>', label = 'Mechanic'},
    [3] = {name = 'ambulance', fa = '<i class="fas fa-user-md"></i>', label = 'EMS'},
}
config.RandomAvatars = { -- if steam avatar is not available, we will use Initials avatar
    [1] = {background = 'ffffff', color = '308BFF'},
    [2] = {background = 'E2E519', color = '222'},
    [3] = {background = 'FF306E', color = 'ffffff'},
    [4] = {background = 'F000FF', color = 'ffffff'},
    [5] = {background = '2F2730', color = 'ffffff'},
}
config.UseDiscordAvatar = false -- if true only discord avatar will be used and not steam (YOU NEED TO INSTALL THIS AND SETUP https://github.com/JaredScar/Badger_Discord_API)
config.UseSelfUploadAvatar = true -- if true steam, discord avatar will be ignored: initials avatar is default if photo is missing/nil