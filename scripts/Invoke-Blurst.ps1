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

# Requires MyTwitter module to be installed/loaded
# If you get this error, need to change the version from * to 1.0 in MyTwitter.psd1
# Cannot convert value "*" to type "System.Version". Error: "Version string portion was too short or too long."
# 
Import-Module -Name MyTwitter 

# Secrets. don't check in, pull from environment variables / app config instead
# Note these are case-sensitive
$APIKey=(Get-ChildItem Env:TWEET-API-key)
$APISecret=(Get-ChildItem Env:TWEET-API-secret)

$AccessToken=(Get-ChildItem Env:TWEET-AccessToken)
$AccessTokenSecret=(Get-ChildItem Env:TWEET-AccessToken-secret)

# One-time configuration on startup
New-MyTwitterConfiguration -APIKey "${APIKey}" -APISecret "${APISecret}" -AccessToken "${AccessToken}" -AccessTokenSecret "${AccessTokenSecret}"
# Send initial tweet to Adam.
# Send-Tweet -Message '@adbertram Thanks for the Powershell Twitter module'

# Speak the suggestion
# based on https://stackoverflow.com/questions/48469588/better-way-to-randomize-from-text-file-in-powershell

# Get a somewhat random phrase
# It's not yet guaranteed random and could be repeated unless state is persisted somewhere.
function Get-RandomPhrase ([String]$InputFileName){
    $lines = get-content $InputFileName
    $phrase= Get-Random -InputObject ($lines | Where{$_ -notin $global:RecentPhrases})
    
    [array]$global:RecentPhrases += $suggestion

    if($global:RecentPhrases.count -gt 20){$global:RecentPhrases = $global:RecentPhrases | Select -Skip 1}
    
    return $phrase
}

# Voice Synthesis
function Speak-Phrase ([String]$Phrase){
    Add-Type -AssemblyName System.Speech 
    $synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $synth.Speak($Phrase)
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

#$Phrase | Out-File testphrase1.txt
#Speak-Phrase -Phrase $Phrase

# Trim the tweet
$TweetMessage = Trim-Tweet -Message $Phrase
#$TweetMessage | Out-File testtweet1.txt
Write-Output $TweetMessage
Write-Output $TweetMessage.Length

# Send the tweet
Send-Tweet -Message '${TweetMessage}'
