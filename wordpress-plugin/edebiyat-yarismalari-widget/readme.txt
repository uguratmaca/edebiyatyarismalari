=== Edebiyat Yarışmaları Widget ===
Contributors: Ugur Atmaca
Tags: literature, competitions, widget, writing, contest
Requires at least: 5.8
Tested up to: 7.0
Requires PHP: 7.4
Stable tag: 1.0.0
License: GPLv2 or later
License URI: https://www.gnu.org/licenses/gpl-2.0.html

Displays current literary competition announcements from edebiyatyarismalari.com on your site via a shortcode.

== Description ==

This plugin lets you display current (not yet past their deadline) literary competition announcements from [edebiyatyarismalari.com](https://edebiyatyarismalari.com) on your site using the `[eyw_widget]` shortcode. Show your visitors up-to-date short story, poetry, novel, and other literary competitions.

The data is fetched from a publicly available JSON feed published by edebiyatyarismalari.com and cached for 12 hours for performance.

= Usage =

Default (first 5 competitions, soonest deadline first):

`[eyw_widget]`

With a specific count and category:

`[eyw_widget count="3" tip="hikaye yarışması"]`

With a heading:

`[eyw_widget baslik="Current Literary Competitions"]`

== Frequently Asked Questions ==

= How often is the data updated? =

The widget refreshes the data published by edebiyatyarismalari.com every 12 hours.

= Are the links to the source site followed (dofollow)? =

No, links are marked with `rel="nofollow sponsored"`.

== Changelog ==

= 1.0.0 =
* Initial release.
