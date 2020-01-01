iex (New-Object Net.WebClient).DownloadString("https://gist.githubusercontent.com/asears/4b4b40776bdda209b6072f7f6f3e1c97/raw/cdbaa86f72663cf80bc49a0bd8d700eb0452b552/InstallMyTwitterModule.ps1")

# Rollback
# Remove-Module -Name MyTwitter
