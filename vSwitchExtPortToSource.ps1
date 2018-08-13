#Get info about Hyper-V virtual switches on host#
$switches = Get-VMSwitch
#Get windows Hyper-V feature
$a = Get-VMSystemSwitchExtensionPortFeature -FeatureId 776e0ba7-94a1-41c8-8f28-951f524251b5
$a.SettingData.MonitorMode = 2
#Adds feature and sets external port to "source" so that Hyper-V will feed data-flow into "destinaton" vNic
add-VMSwitchExtensionPortFeature -ExternalPort -SwitchName $switches[2].Name -VMSwitchExtensionFeature $a
