#Tea

Tea is an app that may never see the App Store, it's primarily just for my own use at the moment.

It's basically a HealthKit integrated tea timer, to keep track of caffeine intake automatically while making cups of tea :)

The caffeine calculations are probably not accurate at the moment, and there are a lot of factors that will alter the true amount in a cup of tea, some impossible to account for, or measure easily, without testing things like water mineral content, perhaps even tea oxidation and age. But we can likely get pretty close and that's good enough.

For now the calculations are probably not too far off, but they're just educated guesses based on a quick look around the web for info on caffeine content in tea.

####State of the code

As of 1.0 the app is a usable, mostly reliable tea timer that properly records caffeine in HealthKit.

There is basic support for backgrounding and notifications, but if you set the timer long enough the app will be suspended before the local notification fires. To resolve that I plan to move the code over to setting a notification for a specific date from the start of the timer.

There is no preference saving of any kind, so for example anything you enter in the text fields will reset when the app quits.

####Features on the roadmap

* Cup history
* Custom tea types with corresponding steep settings saved in iCloud
* Water mineral content settings (if you measure or know yours)
* A smarter caffeine calculation algorithm than what is there now
