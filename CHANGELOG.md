# Changelog :: tumblr_draftking
## Version 0.8.4
+ New: CLI now has (-greedy, -g) flags to select all items in queue before performing action.

## Version 0.8.3.1
+ Fix: Update @blog_url in DK::Client#process_options to target posts for a blog_name modified after DK::Client creation.

## Version 0.8.3
+ New! (Auto-Poster) Publish up to 200 posts per 24 hours!

## Version 0.8.2.2
+ Added patch for tumblr_client 0.8.5 to enable passing of all accepted parameters to Client#likes, Client#blog_likes

## Version 0.8.2.1
+ Expanded progress messages
+ Bugfix: corrected source of Post.comment (data.reblog.comment instead of data.caption)

## Version 0.8.2
+ get_posts now returns FIFO order unless the shuffle option is enabled

## Version 0.8.1.1
+ Bugfix: move_to_drafts was not updating Post.state correctly.

## Version 0.8.1
+ Bugfix: Commands applied to queued posts resulted in post being published.

## Version 0.8.0
+ DK#post_operation now returns both modified count and modified posts. Use `post_operation(opts)[0]` for previous behavior.
+ Access all Tumblr Post data via DK::Post. i.e. `DK::Post.new(post_data).photos.first.original_size.url`
+ Post.image (first photo, original size), Post.alt_sizes, Post.photos (array of Photo structs)

## Version 0.7.0
+ New! (CLI) Store [custom commands](#custom-commands) in .dkconfig then view/execute them using DK ($> dk custom)
+ New! (Posts) #post_operation Reporter dependency injected via options[:reporter], allowing custom report formats.
+ New! (CLI) Manually check for updates using `dk update` (no more auto-notifications)
+ New! (CLI) Updated UI
+ New! (Config) Restructured .dkconfig file format and DK::Config to accommodate new functionality.
+ New! (CLI) Use Reporter for all content output
+ New! (Posts) Support for dashboard access; opts={source: 'dashboard', limit: 50, offset: 0}
+ Bugfix: 'bin/dk' not found error when no default config file is present

## Version 0.6.0.1
+ Changing text 'tumblr' to 'Tumblr'

## Version 0.6.0
+ New! (Reporter) replaces PostReporter. Reporter is generic and can report on any class.
+ New! (Reporter) Added simulation indication.
+ New! (Reporter) Documentation
+ Fix: (CLI::movedrafts) Show correct # of posts being processed
+ (Reporter) Logic tweaks
+ (Post)     Removed named parameters for methods with single parameter (Post) to clean up code

## Version 0.5.2
+ Bugfix: CLI --no-tags option suppresses tag auto-generation (comment, movedrafts, tag)

## Version 0.5.1
+ New! CLI --no-tags option suppresses tag auto-generation (comment, movedrafts, tag)

## Version 0.5.0
+ New! PostReporter - Display summary of modified posts
+ Breaking change: DK::Posts#post_operation now returns both a count of modified posts and the actual posts.
+ Fix: Added accessors for DK::Client.state
+ Fix: Added accessors for DK::Post.blog_url

## Version 0.4.7
+ Bugfix: Handle HTML post comments without getting crazy auto-generated tags
+ Posts now handle logic about their state (changed)
+ Refactored Post Operation threading logic

## Version 0.4.6
+ Bugfix: Automatic determination of movable post limits not being applied when removing old comments
+ Bugfix: Calculation of Queue space adjusted to reflect limit of 300, instead of 301.

## Version 0.4.5
+ Bugfix: movedrafts incorrectly limited by size of queue instead of available space in queue.

## Version 0.4.4
+ CLI now displays a notification when a new version is available

## Version 0.4.3
+ Performance improvement: Faster processing of posts with multi-threading
+ Bugfix: Missing 'console' command
+ Bugfix: Passing a Limit > 50 was only applying to first 50 posts
+ Bugfix: Non-queue related operations were being limited by available queue space
+ Automated injection of change log information into README

## Version 0.4.2
+ Bugfix: Drafts not moving to queue

## Version 0.4.1
+ Bugfix for queued posts.  Posts in the queue have a state 'queued'. In order to save them back in the queue state needs to be changed to 'queue'.

## Version 0.4.0
+ Code refactoring: consolidate option processing to simplify code.
+ Updated header image

## Version 0.3.1
+ Update credit tag

## Version 0.3.0
+ New CLI! The Command Line Interface has been redone using [Thor](https://github.com/erikhuda/thor)
+ CLI can now save and switch between multiple [account configurations](./README.md#configured-accounts)
+ Added a [CHANGELOG](./CHANGELOG.md)
+ Added a repository header image
+ Improved test coverage
+ Cleared out [.rubocop_todo.yml](./.rubocop_todo.yml) to reflect true codeclimate

## Version 0.2.2
+ Improved documentation
+ Reduced test suite runtime
+ Code cleanup
