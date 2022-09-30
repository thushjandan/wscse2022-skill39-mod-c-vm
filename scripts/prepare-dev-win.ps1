# Install chocolately
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install required software via choco
$validExitCodes = @( 0, 3010 )
@(
    @{ name = "python" },
    @{ name = "zeal.install" },
    @{ name = "vscode" },
    @{ name = "postman" },
    @{ name = "pycharm-community" }
) | foreach {

    $command = 'choco.exe upgrade $($_.name) -y --no-progress '
    if ($_.ContainsKey('args')) {
        $command += $_.args
    }
    
    Invoke-Expression -Command $Command
    #if ($LASTEXITCODE -notin $validExitcode) {
    #    throw "We had an error"
    #}
}

refreshenv

# Install VSCode extensions
& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --install-extension ms-vscode-remote.remote-ssh --force
& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --install-extension ms-python.python --force
& "C:\Program Files\Microsoft VS Code\bin\code.cmd" --install-extension redhat.ansible --force

# Download docsets for Zeal
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile("https://kapeli.com/feeds/zzz/versions/Python_3/3.9.2/Python_3.tgz", 'C:\Windows\Temp\Python_3.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://kapeli.com/feeds/zzz/versions/Ansible/2.10.8/Ansible.tgz", 'C:\Windows\Temp\Ansible.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://kapeli.com/feeds/zzz/versions/Jinja/2.11.3/Jinja.tgz", 'C:\Windows\Temp\Jinja.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://kapeli.com/feeds/zzz/versions/Django/2.2.7/Django.tgz", 'C:\Windows\Temp\Django.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://kapeli.com/feeds/zzz/versions/Flask/1.1.2/Flask.tgz", 'C:\Windows\Temp\Flask.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://drive.switch.ch/index.php/s/QLto1t9DH076F49/download", 'C:\Windows\Temp\CiscoYangModel.tar.gz')
New-Item C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets -ItemType Directory
tar -xzf C:\Windows\Temp\Python_3.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Ansible.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Jinja.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Flask.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Django.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\CiscoYangModel.tar.gz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets

# Download Postman Collection
(New-Object System.Net.WebClient).DownloadFile("http://$env:PACKER_HTTP_ADDR/WSCSE2022_Module_C_API.postman_collection.json", "$HOME\Desktop\WSCSE2022_Module_C_API.postman_collection.json")