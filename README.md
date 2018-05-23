# JamfCloud-Check

<b>JamfCloud Check</b> is a simple script that leverages ping and hping to check the status and responsiveness of Jamf Cloud environments. Depending on the results, it will use the mail binary to send an (absolutely untrusted and suspicious looking) email to a specified inbox.
<br>
* hping: http://www.hping.org
<br>
This script is designed to be cron-jobbed - I ran it on a 15-minute basis. It will produce some false alarms, but in my experience only the "high latency event detected" alarms would ring - the server would respond to requests, but hping would take too long, or there would be packet failure along the way.
