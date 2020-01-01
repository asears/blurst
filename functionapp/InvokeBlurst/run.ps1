using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

if ($name) {
    $status = [HttpStatusCode]::OK
    $body = "Hello $name"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "Please pass a name on the query string or in the request body."
}

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
# $InputFileName="..\data\crowdsourced_all.txt"
#$Phrase = Get-RandomPhrase -InputFileName $InputFileName
$Phrase = "tweet tweet from Azure Powershell Functions"

# Trim the tweet
$TweetMessage = Trim-Tweet -Message $Phrase

# Send the tweet
Send-Tweet -Message '${TweetMessage}'

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body
})
