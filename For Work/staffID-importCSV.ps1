#################################################
#
# Imports a set of Users from CSV and tests for 
# Enabled accounts and for date password was last set
#
# By: jmthurman@okcps.org   6/18/2014  Rev 1.0
#
#################################################
import-module activedirectory


#$ADuser = Read-Host "Enter Staff UserName:"

# Import CSV File

$csvPath = Read-Host "Enter the path to your csv file in the form [drive]:\[folder path]\[filename].csv "

$ADusers = Import-Csv -Path $csvPath

# Count $ADusers

$count = 0

foreach ($ADuser in $ADusers){
    $count++
}

# Declare Array

#$passSet = (1..$count)
#$accountEnabled= (1..$count)

# Get AD user info 

#$i = 1

foreach($ADuser in $ADusers){

$userID = Get-ADUser $ADuser.userID -Properties * | select -Property @("PasswordLastSet", "Enabled")
#$passSet = $userID.PasswordLastSet
#$acctEnabled = $userID.Enabled
#$userName = $ADuser.userID
$ADuser.Enabled = $userID.Enabled
$ADuser.passSet = $userID.PasswordLastSet
#Write-Host -ForegroundColor Blue -BackgroundColor Yellow "Username: $userName Enabled: $acctEnabled Password last set:$passSet" 
}
#$IDnum = $userID.employeeID

# Export csv

$ADusers | Export-csv -Path c:\pstemp\tfapwdrpt2.csv

