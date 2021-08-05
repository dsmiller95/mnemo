# Mnemo

- [What is Mnemo?](#what-is-mnemo)
- [Using Mnemo](#using-mnemo)
- [Installing Mnemo](#installing-mnemo)
  - [Docker](#docker)
- [My Experience](#my-experience)
- [License (GNU General Public License)](#license-gnu-general-public-license)


## [What is Mnemo?](#what-is-mnemo)

"mnemo" is an education aide written by Rick Miller <rdmiller3@gmail.com>

A lot of things can be learned by memorization in a question-answer format.
Students commonly use repetition and "flash cards" with some success but
this program is written to optimize the process and to carry it further.

Typical memorization techniques end after the accomplishement of an
immediate goal, such as passing a vocabulary test.  This program however
refreshes the knowledge so that it becomes long-term memory.  With regular
use at your own pace, all of the things you learn with mnemo can be
remembered indefinitely.  You won't need to "cram" before an examination if
you've been using mnemo for that subject.  All the items you memorized for
your first quiz will be just as fresh as (or better than) they were before.


## [Using Mnemo](#using-mnemo)

Initially, you log in and start out in "quiz mode".  You are shown a
"question".  Your goal is to think of the "answer" for that question.  Then
click the "Show answer" button and judge how well you did.  You judge
yourself.  Be honest because it's in your own best interest.

    "Huh?": I couldn't even guess what the answer might be.
    "No":   My answer was wrong.
    "Slow": I got the right answer but it took more than a second or two.
    "Yes!": I got the right answer right away.


After clicking the button which describes how well you answered, you will
be given another question.  A session proceeds this way for fifteen minutes
by default, then gives you a report showing how many times you clicked each
of the answer-grade buttons.  You can do just a few minutes at a time if
you like, and at any time whenever you feel like it.  mnemo adapts to
real-world time because that's how your brain grows.

The basic principle behind mnemo is an accellerating "interval".  Every
time you get an answer right, mnemo will wait a longer time before showing
you that question again.  If you get it wrong the interval will be somewhat
shorter.  Most of the time, you will be getting the answers right and
accellerating the memories farther and farther into the future.

When creating items, try to make them the smallest amount of information
which makes sense in the context of the group.  For example, when learning
a language you should enter vocabulary words as items.  Longer items could
easily be confusing because there may be more than one correct way to say
the same thing.

When creating new groups of items, remember to name the group so that it
makes sense in a global context.  Group names like "vocabulary for class
tomorrow" will be confusing at a later time and you won't know if it's for
Spanish or for Anatomy.  "Spanish 1 - lesson 3" is a good example because
several years from now you will still know what it means.

Enter your data as early as you can.  The algorithm behind mnemo is not
made for "cramming".  (It helps, but that's not the point!)  Create items
for material while you are just freshly learning it.  Make corrections if
necessary after you have a better understanding of the material.  Then, if
you are using mnemo regularly, you will be ready to be tested on that
material at any time... and mnemo will keep it fresh for later tests, even
while you're learning new material.

With regular use, you will typically maintain a 95% recall rate (either
"Slow" or "Yes!" answers) for all the items you have ever learned with
mnemo.  And even if you quit using it for a week, or a month, or several
months, mnemo will pick right up with the things you know best and bring
the other items back into your recollection without restarting the process.
It's really amazing how rapidly you can be brought back up to speed and
learning new items again.


## [Installing Mnemo](#installing-mnemo)

"mnemo" was originally intended for use with "HTTPi", but it's
basically a CGI program so it was changed to work with Apache2.
(HTTPi scripts are expected to print the "HTTP 1.0 200 OK" line
immediately before the usual "Content-type:" header.)

The $opsDir variable near the beginning of the "htdocs/mnemo" file
should be set to point to some directory to use as your
local "mnemo_ops".  See the included "mnemo_ops" directory for a
template of what should be found there.  Your "mnemo_ops" directory
must be writable for the UID under which the CGI program will run.

### [Docker](#docker)

Mnemo now supports docker. To build and run an instance locally, simply run `sh refreshDocker.sh` from the root directory. This will start a new mnemo server, and mount the `mnemo_ops` directory to 

## [My Experience](#my-experience)

mnemo started as a flash-card script in Perl to help me learn Esperanto.
(Visit http://Lernu.net for more about Esperanto.)  I started working on it
some time in 2002 and had something usable by January of 2003.  By June, I
was chatting online about common topics in Esperanto and passed a
beginner-level language exam.  By December, I was reading books, enjoying
podcasts and participating in conversation in Esperanto and passed a
mid-level exam.  In July of the following year I participated in an
international conference in Esperanto, passed an advanced-level exam and
worked as a volunteer translator for an independent film company.

You would hardly guess that I was a terrible student.  I wasn't consistent
at all.  There were whole weeks when I skipped using mnemo.  I even skipped
a couple months during that time.  I didn't use mnemo at any regular time,
just whenever I felt like it.  Sometimes I used mnemo for a fifteen minute
session and sometimes several times a day for just a few minutes each.
These were not the habits of a good student.

I have to admit that Esperanto was designed to be easy to learn... but I
still can't help being amazed that I was able to attain fluent speech and
literacy in a foreign language in only 18 months.  Many times I was
complimented on my knowledge of vocabulary, which I learned using mnemo.
Being confident about the vocabulary was one of the main reasons that I was
able to make such rapid progress.

I use mnemo for some other things too.  I used mnemo to learn the Loraine
"peg system" for remembering numbers.  That makes it easier to use mnemo
for learning phone numbers, insurance numbers, birthdays and such.   I also
learned a small constructed-language called Toki Pona.  In all, I have
memorized more than 8000 items in the past three and a half years.


## [License (GNU General Public License)](#license-gnu-general-public-license)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

