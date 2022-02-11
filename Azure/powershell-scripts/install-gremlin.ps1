#Installing the Gremlin Client onto Windows VM Script

#Install the package
msiexec /quiet /package https://windows.gremlin.com/installer/latest/gremlin_installer.msi

#Set the environment variables
[Environment]::SetEnvironmentVariable("GREMLIN_IDENTIFIER", "$(hostname)", "Machine")
[Environment]::SetEnvironmentVariable("GREMLIN_TEAM_ID", "42812f71-0159-4588-812f-710159258899", "Machine")
[Environment]::SetEnvironmentVariable("GREMLIN_TEAM_SECRET", "f2e948ad-da5d-48cf-a948-adda5da8cf98", "Machine")

#Restart the service
net stop gremlind
net start gremlind
