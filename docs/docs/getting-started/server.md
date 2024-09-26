# Server

Currently, the easist way to setup a server is to use a free / serverless
instance from [EMQX](https://accounts.emqx.com/signin?continue=https%3A%2F%2Fcloud-intl.emqx.com%2Fconsole%2F).

Instructions for hosting your own broker locally and exposing it to the public
internet will be available in the future.

## EMQX - Cloud Hosted

1. Register for a free account with [EMQX](https://www.emqx.com/en) and sign in
2. Create a new deployment
3. Choose "Serverless" with a $0.00 spend limit and choose a name
4. Under "Overview", make note of the address and MQTT port
5. Under "Access Control" -> "Authentication", add a new username and password
6. Use the values from #4 and #5 when setting the "Host", "Port", "Username" and
   "Password" values in the [mobile app](mobile-app)
