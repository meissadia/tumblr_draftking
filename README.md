# DraftKing for tumblr
[![Gem Version](https://badge.fury.io/rb/tumblr_draftking.svg)](https://badge.fury.io/rb/tumblr_draftking)
[![Code Climate](https://codeclimate.com/github/meissadia/tumblr_draftking/badges/gpa.svg)](https://codeclimate.com/github/meissadia/tumblr_draftking)
[![Test Coverage](https://codeclimate.com/github/meissadia/tumblr_draftking/badges/coverage.svg)](https://codeclimate.com/github/meissadia/tumblr_draftking/coverage)

Take the hassle out of managing your tumblr drafts!  
+ Automated addition of comments and tags.  
+ Strip away old comments.
+ Easily replenish your queue using your drafts.

Version 0.2.2
+ Improved documentation
+ Reduced test suite runtime
+ Code cleanup
+ Please report any [issues](https://github.com/meissadia/tumblr_draftking/issues) you encounter!

## Table of Contents
+ [Installation](#installation)
+ [Setup](#setup)
+ [Usage](#usage)
	+ [Program](#program)
	+ [Command Line Interface](#command-line-interface)
		+ [My Workflow](#my-workflow)
		+ [Other Examples](#other-examples)
			+ [Blog list](#blog-list)
			+ [Commenting](#commenting)
			+ [Drafts or Queue](#drafts-or-queue)
			+ [Stripping Comments](#stripping-comments)
			+ [Comment & Move](#comment-&-move)
		+ [Testing Console](#testing-console)
+ [Contributing](#contributing)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tumblr_draftking'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tumblr_draftking

## Setup

Running DK setup will save your configuration for future use (~/.dkconfig)  

1. Register an app: https://www.tumblr.com/oauth/apps  
1. Access API Keys: https://api.tumblr.com/console/calls/user/info  
You'll need four values:  
  * consumer_key
  * consumer_secret
  * oauth_token
  * oauth_token_secret  

```ruby
$ dk setup
```


## Usage

### Program
API Keys can be read from ~/.dkconfig (See: [Setup]) or you can pass them at the time of Client creation.

```ruby
require 'tumblr_draftking'

# Use default configuration file: ~/.dkconfig
dk = DK::Client.new()

# Specify your own configuration file
dk = DK::Client.new(config_file: filename)

# Define directly
dk = DK::Client.new(keys: { consumer_key:       'your value',
                            consumer_secret:    'your value',
                            oauth_token:        'your value',
                            oauth_token_secret: 'your value' })

```

Documentation available on [rubydoc.info](http://www.rubydoc.info/gems/tumblr_draftking/0.2.2)

### Command Line Interface

The CLI will walk you through connecting to your tumblr account the first time it's run.

* See: [Setup]

Once you've got that configured, check the help to familiarize yourself with your options.

```ruby
$ dk -h
```

#### My Workflow
1. I'll usually manually add comments for posts where I want more detail and use a separator to indicate which portions should be added as tags.
```
  ~ MD ~ | architecture \ landscape / blue , yams
```
1. Once I have my special cases taken care of I'll use DraftKing to automatically tag the rest, strip old comments and move them to my queue.  
  * It will preserve any comments which already have the '~ MD ~' tag, so I don't need to worry about losing my special cases.  
  * It will also generate tags from the comment.  In the above case you would get: #architecture #landscape #blue #yams

  ```
    $ dk c_and_m -c '~ MD ~' -k false  
  ```


#### Other Examples

##### Blog list
```ruby
$ dk blogs
#> #-------- Blogs --------#
#> 1. 'first-blog-name'
#> 2. 'second-blog-name'

```

##### Commenting
Add the comment 'my blog rocks!' to all drafts of blog 'first-blog-name'

```ruby
$ dk comment -c 'my blog rocks!'

#> Adding draft comment "my blog rocks!": 32 / 32 [100%]

```

##### Drafts or Queue  
Add the comment 'my queue rolls!' to all queued posts of blog 'first-blog-name'  

`--source only compatible with 'comment' or 'strip'`  

```ruby
$ dk comment -c 'my queue rolls!' --source q

#> Adding queue comment "my queue rolls!": 32 / 32 [100%]

```

##### Stripping Comments
Remove old comments from 'second-blog-name' drafts

```ruby
$ dk strip -b 'second-blog-name'

#> Stripping previous comments: 113 / 113 [100%]

```

##### Comment & Move
Add the comment "Q'd" to all of your drafts, remove old comments and move them into your Queue.
Omitting the -b blog_name option defaults to using the main blog

```ruby
$ dk c_and_m -c "Q'd" -k false

#> Moving Drafts -> Queue: 113 / 113 [100%]

```

### Testing Console
The dk console can act as a sandbox while you explore the api or you can use it to actively manage your account.  
By default it runs in simulation mode so any changes you make will not affect your account.

```ruby
$ dk console
irb:> $dk.status
irb:> $dk.strip_old_comments

# Switch to live mode
irb:> $dk.simulate = false

```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meissadia/tumblr_draftking.

<br/>
<br/>
<br/>
<br/>
<br/>
(c) 2016 Meissa Dia

[Setup]: #setup
