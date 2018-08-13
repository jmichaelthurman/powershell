import-module activedirectory
$ADuser = Read-Host "Enter Student UserName:"
$userID = Get-ADUser $ADuser -Properties * -Server "<DC-hostname>" | select -Property "VcuserUniqueId"
$IDnum = $userID.VcuserUniqueId
write-host -ForegroundColor Red -BackgroundColor Yellow "Student $ADuser ID number is $IDnum"