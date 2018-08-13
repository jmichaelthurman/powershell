import-module activedirectory
$ADuser = Read-Host "Enter Staff UserName:"
$userID = Get-ADUser $ADuser -Properties * | select -Property @("PasswordLastSet", "Enabled")
#$IDnum = $userID.employeeID
$passSet = $userID.PasswordLastSet
$acctEnabled = $userID.Enabled
Write-Host -ForegroundColor Blue -BackgroundColor Yellow "Staff Username: $ADuser Enabled: $acctEnabled Password last set:$passSet" 