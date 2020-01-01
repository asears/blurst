<#
.SYNOPSIS

Invokes a Blurst to Twitter

.DESCRIPTION

Reads a text file
Sends the output as a twitter message
Optional speech synthesis for local testing
Uses environment variables / app settings for secrets

.PARAMETER Name
Specifies the file name.

.INPUTS

None. 

.OUTPUTS

None.

.EXAMPLE

#>
# First time Powershell install
# Set-executionpolicy remotesigned

# Requires PSTwitterAPI module to be installed/loaded

# Installation
# Install-Module PSTwitterAPI -Scope CurrentUser

Import-Module -Name PSTwitterAPI


# Secrets. don't check in, pull from environment variables / app config instead
# Note these are case-sensitive
# TODO naming, key vault

$OAuthSettings = @{
  ApiKey = (Get-ChildItem Env:TWEET-API-key)
  ApiSecret = (Get-ChildItem Env:TWEET-API-secret)
  AccessToken = (Get-ChildItem Env:TWEET-AccessToken)
  AccessTokenSecret = (Get-ChildItem Env:TWEET-AccessToken-secret)
}
Set-TwitterOAuthSettings @OAuthSettings
# Use one of the API Helpers provided:
$TwitterUser = Get-TwitterUsers_Lookup -screen_name 'blurstoftimes1'

# Send tweet to your timeline:
#Send-TwitterStatuses_Update -status "Hello World!! @mkellerman #PSTwitterAPI"

# Get a somewhat random phrase
# It's not yet guaranteed random and could be repeated unless state is persisted somewhere.
function Get-RandomPhrase ([String]$InputFileName){
    $lines = get-content $InputFileName
    $phrase= Get-Random -InputObject ($lines | Where{$_ -notin $global:RecentPhrases})
    
    [array]$global:RecentPhrases += $suggestion

    if($global:RecentPhrases.count -gt 20){$global:RecentPhrases = $global:RecentPhrases | Select -Skip 1}
    
    return $phrase
}


# Trim the string to be compatible with Twitter post
# Multiple 140-character post/reply messages could also be sent
function Trim-Tweet ([String]$Message){
    # tweets are max 140 characters, if it's greater then trim to 137 and add ... to end
    if($Message.Length -gt 140){ $TweetMessage = $Message.Substring(1,137) + "..."}
        else { $TweetMessage = $Message}
    return $TweetMessage
        
}

# Get a crowdsourced novel first lines dataset from Janelle Shane (buy her book!)
# https://github.com/janelleshane/novel-first-lines-dataset
$InputFileName="..\functionapp\data\crowdsourced_all.txt"
$Phrase = Get-RandomPhrase -InputFileName $InputFileName
Write-Output $Phrase

# Trim the tweet
$TweetMessage = Trim-Tweet -Message $Phrase
#$TweetMessage | Out-File testtweet1.txt
Write-Output $TweetMessage
Write-Output $TweetMessage.Length

# Send the tweet
Send-TwitterStatuses_Update -status '${TweetMessage}'

