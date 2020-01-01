# Blurst

## *It was the best of times, it was the blurst of times!*

Blurst is a Twitter bot which Tweets random 140 character one-liners.

It is currently implemented as a Powershell script and an Azure Powershell Function app.

## Build

There's no build for Powershell.

## Run

```
func start
```

## Tests

### Local Tests

1. Setup the environment variables locally.
2. Run the scripts\Invoke-Burst.ps1 script
3. Verify tweets

### Remote Tests

1. Hit http url for function app.
2. Review Appinsights for Errors and Warnings.

## Deployment

1. Create an Azure Powershell Function App
2. Add environment variable settings as per scripts/Invoke-Blurst.ps1
3. Deploy the app.

## Developer Notes

### Custom Modules

After running func init to create the project, create a folder called Modules.  Copy the custom modules to the folder.

## TODOs

* Storage account or github url for random data tweet
* Timer CRON schedule for tweets
* Pester tests
* Update docs
* Additional Azure integration

## Contributions

Feel free to provide any feedback or code contributions.  This repo isn't frequently maintained.

## References

## Get a crowdsourced novel first lines dataset from Janelle Shane (buy her book!)
https://github.com/janelleshane/novel-first-lines-dataset
