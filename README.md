# lincoln

Lincoln is our personal bot. We host him on Heroku.

Lincoln was inspired by a talk about ChatOps and how much you can use slack and bots to automate your workflow. Lincoln aims to be able to get out of your way and let you start building great applications.

## What he does

Lincoln handles the lifecycle of our aws instances. You just have to ask Lincoln to do it for you and he takes care of all the nitty gritty for you.

## How he works

Lincoln is still under development but his initial version is based off of webhooks and a bot user. Currently Lincoln is only active on the [#lincoln-test](https://carletonslam.slack.com/messages/lincoln-test/) channel.

If you start a message with `link` it'll send a webhook to our friend living in heroku. He'll then parse your command, do any necessary work, and respond.

## What he needs to improve on

Currently there's a limitation on the webhook based triggers. You cannot, for example, activate lincoln from private channels. He needs to be revamped to use the [RTM API](https://api.slack.com/rtm). A good place to investigate further is the [ruby-slack-client](https://github.com/dblock/slack-ruby-client) gem.

Also, more features.

## Commands

In slack type `link help` to get an up to date list of commands.

### Development

Set up your environment variables by adding the following to your `.zshrc` or `.bashrc`

```bash
export LINCOLN_WEBHOOK_TOKEN='xxxxx-xxxxxxx-xxxxxxxxxxxx'
export LINCOLN_API_TOKEN='xxxxxxxxxxxxxxxxx'
```

Next add our keypair file to `~/.ssh/slam.pem` you can obtain it from running `link ec2 keypair` in slack.

finally setup the ruby project with `bundle install` and run it with `bundle exec ruby lib/app.rb`.

You can test it with `curl -X POST localhost:4567/gateway -d @test/help.json` and see the response show up in slack.
