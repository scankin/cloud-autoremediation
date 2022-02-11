
$fileContents = "identifier: $(hostname) `nteam_id: 42812f71-0159-4588-812f-710159258899`nteam_secret: f2e948ad-da5d-48cf-a948-adda5da8cf98"

msiexec /package https://windows.gremlin.com/installer/latest/gremlin_installer.msi /qn
Start-Sleep -s 20
$fileContents | Out-File -FilePath C:\ProgramData\Gremlin\Agent\config.yml

net stop gremlind
net start gremlind
