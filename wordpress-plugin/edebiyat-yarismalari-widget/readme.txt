=== Edebiyat Yarışmaları Widget ===
Contributors: atmacaugur
Tags: literature, competitions, widget, writing, contest
Requires at least: 5.8
Tested up to: 7.1
Requires PHP: 7.4
Stable tag: 1.0.1
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Displays current literary competition announcements from edebiyatyarismalari.com on your site via a shortcode.

== Description ==

This plugin lets you display current (not yet past their deadline) literary competition announcements from [edebiyatyarismalari.com](https://edebiyatyarismalari.com) on your site using the `[edyw_widget]` shortcode. Show your visitors up-to-date short story, poetry, novel, and other literary competitions.

The data is fetched from a publicly available JSON feed published by edebiyatyarismalari.com and cached for 12 hours for performance.

= Usage =

Default (first 5 competitions, soonest deadline first):

`[edyw_widget]`

With a specific count and category:

`[edyw_widget count="3" tip="hikaye yarışması"]`

With a heading:

`[edyw_widget baslik="Current Literary Competitions"]`

== Frequently Asked Questions ==

= How often is the data updated? =

The widget refreshes the data published by edebiyatyarismalari.com every 12 hours.

= Are the links to the source site followed (dofollow)? =

No, links are marked with `rel="nofollow sponsored"`.

== External services ==

This plugin connects to edebiyatyarismalari.com, the site it is published by, to retrieve the list of current literary competition announcements shown by the `[edyw_widget]` shortcode.

It sends a plain server-side HTTP GET request to `https://edebiyatyarismalari.com/yarismalar.json` (a static, publicly available JSON feed) whenever the 12-hour cache has expired. No visitor data (IP address, cookies, user agent, or any other personal or site data) is included in this request — it is a fixed URL with no parameters. The response (competition titles, URLs, deadlines and prize info) is cached locally as a WordPress transient for 12 hours.

This service is provided by edebiyatyarismalari.com: [Privacy Policy](https://edebiyatyarismalari.com/gizlilik/). The site does not publish a separate terms-of-use page; the JSON feed is offered as public data for reuse.

== Changelog ==

= 1.0.1 =
* Prefixed all functions, classes, hooks, options and the shortcode tag with `edyw_`/`EDYW_` to avoid namespace collisions (shortcode is now `[edyw_widget]`).
* Documented the external service call (edebiyatyarismalari.com JSON feed) per the Plugin Directory guidelines.
* Added Contributors username.

= 1.0.0 =
* Initial release.
