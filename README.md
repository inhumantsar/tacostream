# tacostream - never. log. off.

streams /r/neoliberal's busyass discussion thread in a more chat-like format.

## wtf for?

why not? 

## what's the plan?

1. to not get bloated.
2. stay focused on the dt.
3. have fun with it.

## how does it work?

1. an ingestion service listens to r/neoliberal for new comments
2. comments on the dt get tossed on to a pub/sub topic.
3. a small web service subscribes to the topic and listens for connections from the app.
4. any new comments the web service gets via the subscription get relayed to any connected apps.

### why add all these extra services?

there's only so much you can do with an app. 