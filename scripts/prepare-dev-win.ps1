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
Code --install-extension ms-vscode-remote.remote-ssh --force
Code --install-extension ms-python.python --force
Code --install-extension redhat.ansible --force

# Download docsets for Zeal
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(New-Object System.Net.WebClient).DownloadFile("http://tokyo.kapeli.com/feeds/Python_3.tgz", 'C:\Windows\Temp\Python_3.tgz')
(New-Object System.Net.WebClient).DownloadFile("http://tokyo.kapeli.com/feeds/Ansible.tgz", 'C:\Windows\Temp\Ansible.tgz')
(New-Object System.Net.WebClient).DownloadFile("http://tokyo.kapeli.com/feeds/Jinja.tgz", 'C:\Windows\Temp\Jinja.tgz')
(New-Object System.Net.WebClient).DownloadFile("http://tokyo.kapeli.com/feeds/Django.tgz", 'C:\Windows\Temp\Django.tgz')
(New-Object System.Net.WebClient).DownloadFile("https://drive.switch.ch/index.php/s/QLto1t9DH076F49/download", 'C:\Windows\Temp\CiscoYangModel.tar.gz')
New-Item C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets -ItemType Directory
tar -xzf C:\Windows\Temp\Python_3.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Ansible.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Jinja.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\Django.tgz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets
tar -xzf C:\Windows\Temp\CiscoYangModel.tar.gz -C C:\Users\appadmin\AppData\Local\Zeal\Zeal\docsets