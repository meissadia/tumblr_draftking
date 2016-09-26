# Changelog :: tumblr_draftking
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
