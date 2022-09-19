# Change IP of Ethernet0
New-NetIPAddress -IPAddress "$env:WSC_IP" -PrefixLength 24 -ifIndex (Get-NetAdapter -Name Ethernet0 | Select -ExpandProperty ifindex)
# Shutdown
shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"