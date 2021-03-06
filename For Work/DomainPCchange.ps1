#Import module to do AD checks
import-module activedirectory

#Get AD staff Password
#$ADPassword = Read-Host "Enter your Staff Password:"

#set current PC name to variable
$computer = Read-Host "Enter Current Computer Name:"

#set new site number to variable
$site = Read-Host "Enter New Site Number"

#sets admin username and password to variable.
$cred = Get-Credential $computer\administrator

#Get AD staff username
$ADusername = Read-Host "Enter your Staff Username:"

#sets Staff\user username and password to variable.
$credAD = Get-Credential staff\$ADUserName

#pings PC to see if Alive. If Alive, continue.  If not, Stop.
if (test-connection $computer -quiet) {
	write $computer' is ready for renaming'
} else {
	write $computer' not turned on, Stopping Script'
	exit
}

# query nics for active IP Address and shortens it to the first two octets (10.10.10.145 to 10.10)
#Gets IP Address of remote computer
#$Colitems3 = gwmi -class Win32_NetworkAdapterConfiguration -Credential $cred -Namespace "root\civ2" -ComputerName $computer | where{$_.IPEnabled -eq "True"}

#Get IP colitems3 and put it in to a variable
#$IP = $colitems3.IPAddress[0]

#Splits the IP and rejoin only with the first two Octets
#$shortIP = ($ip.split(".")[0..1]) -join(".")

#Get school string from text file using shortIP variable 
#$data = select-string -Path c:\Altiris\Schoolips.txt -pattern "$shortIP\b"

#split data until all that is left is site number
#$data2 = $data -split ":"
#$data3 = $data2[3]
#$data4 = $data3 -split " "
#$site1 = $data4[1]

#queries bios info to variable
$ColItems = Get-WmiObject -Class Win32_SystemEnclosure -Credential $cred -Namespace "root\cimv2" -ComputerName $computer

#finds serial number and set to variable
$Serial = $ColItems.SerialNumber

#queries pc system info to variable.
$ColItems2 = Get-WmiObject -Class Win32_ComputerSystem -Credential $cred -Namespace "root\cimv2" -ComputerName $computer

#finds PC name and sets to variable.
$Computer2 = $ColItems2.Name
write-host 'Old PC is:'$Computer2

#sets new pc name to variable from other variables and show Value.
$newcomputer = "$site-$serial"
#$newcomputer = "$site1-$serial"
write-host 'New PC is:'$newcomputer

#From site Variable, get value from site hashtable and set to variable
$hashtable = Get-variable $site
#$hashtable = Get-variable $site1

#write out TargetOU from new site and set variable.
Write-host $hashtable.Value.TargetOU
$target = $hashtable.Value.TargetOU

#Write out GroupID from new site and set Variable.
Write-Host $hashtable.Value.GroupID
$group = $hashtable.Value.GroupID

#check to see if newname exists both network and AD
if (test-connection $newcomputer -quiet) {
	write $newcomputer' is active, that sucks'
} else {
	write $newcomputer' is not on Network, continuing'
}

#Check if New PC has an Object
$status = Get-ADComputer -Identity $newComputer -Properties * | select enabled
if ($status -eq $f) {
    Write-Host "$NewComputer is disabled"
} else {
    Write $newcomputer' does exist, removing object.'
	Remove-ADComputer $newcomputer -Credential $credAD -Confirm:$false
}
# $computerAD = Get-ADComputer $newcomputer
# Remove-ADObject $computerAD.DistinguishedName -Recursive -Confirm:$false

#Moving computer to new OU container.
$results = get-adcomputer $Computer2
move-adobject $results.DistinguishedName -TargetPath $Target 
Write-Host "$computer2 has moved to new container"

#Applying remove old and add new Security Group
$results2 = get-adcomputer $Computer2
$sam = $results2.SamAccountName
$Member = Get-ADComputer $computer2 -Properties * | Select-Object MemberOf
$data = $Member.MemberOf -split ","
$data2 = $data[0] -split "="
$data3 = $data2[1]
Remove-ADGroupMember -Identity $data3 -Members $sam -Confirm:$false
ADD-ADGroupMember $group –members $results2.DistinguishedName
write-host "$computer2 was added to security group"

#Renaming computer on the domain
$ComputerWMIObject = Get-WmiObject -Class Win32_ComputerSystem -Credential $cred -Namespace "root\cimv2" -ComputerName $computer2 -Authentication 6

#Rename the Computer Object with your or some admin credentials (Yes, Password is the second parameter and username the third )
$result = $ComputerWMIObject.Rename("$newComputer", "12345678A!" , "Staff\bmc" )
$result.ReturnValue