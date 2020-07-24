pplsearch
==========


# pplsearch: An addressbook searcher for use with a mess of vcards

## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Usage](#5-usage)
 6. [VCardreader](#6-vcardreader)
 7. [VCardfixer](#7-vcardfixer)
 8. [Tip](#8-tip)
 9. [TODO](#9-todo)

***

I really liked [ppl](https://web.archive.org/web/20170610235714/http://ppladdressbook.org/) and the control it 
gave you over your contacts. I was thrilled to find [vdirsyncer](https://github.com/pimutils/vdirsyncer) 
and the way it can sync your contacts with multiple services. But I wanted a way to be able to 
quickly and easily search through my contacts for basic information and, if I wanted,  
to have a GUI to do it. 

As `ppl` is now defunct, this script has taken the place of accessing (though 
not *editing*) my addressbook quickly and easily with a GUI or TUI.

This is a complete overhaul from prior versions.

## Requires

All of these are available in Debian (and presumably Ubuntu) as packages:

`sudo apt install vdirsyncer rofi fzf zenity ripgrep`

* [zenity](https://help.gnome.org/users/zenity/stable/) or a drop-in replacement like [matedialog](https://github.com/mate-desktop/mate-dialogs) or 
[wenity](http://freecode.com/projects/wenity) for viewing GUI output
* [fzf](https://github.com/junegunn/fzf) - Provides TUI for selecting VCard
* [rofi](https://github.com/davatorium/rofi) - Provides GUI for selecting VCard
* [vdirsyncer](https://github.com/pimutils/vdirsyncer) with the "filesystem" option
* [ripgrep](https://github.com/BurntSushi/ripgrep) for faster grepping

Trust me, you want to check out `fzf`, `rofi`, and `ripgrep` anyhow.

## Installation

Place the script somewhere in your PATH or symlink it to such.  
If your VCards are somewhere other than `$HOME/.contacts/contacts` you will 
need to edit line 14 to reflect the location of your contacts.


## Usage

`pplsearch [-h|-m|-c]`

Call the script (from the command line, a launcher, or an Openbox menu) 
and it will search for any string in a directory full of vcards. If `ppl` 
is installed, it will use the `ppl` configuration file to determine where 
to search, otherwise it uses the current directory. 

If no matches are available, you'll be told, otherwise you will be able 
to select from a list of full names (or given the single match if that's 
the case). Then the full info of the person will be presented to you.

If you do not have `ppl` installed, this will *work*, thanks to grep and 
sed, but the final output isn't quite as pretty.

If you do not have `vdirsyncer` set up, you'll have to get the vcards 
there some other way (say, exporting from your mail client).


## Related

The `vcardfixer.sh` script is there to simply fix some small irregularities 
in individual vcards so that `ppl` can handle them properly. Currently 
it handles the lack of the N: field (and properly swaps last and first 
names) and the lack of an END:VCARD field. It's a pretty simple bash 
script (though finding out that a rogue carriage return was causing me 
problems took forever), so if you have another field that's causing 
problems, you can fix it.

## Use your contacts as a git repository

While slightly afield from the scope of this script, I found it useful to 
make your contacts directory a git repository so that you can check and revert 
changes from syncing.  

Set up vdirsyncer properly, and when it's all configured, call it with a wrapper 
script like this:

```
		/usr/bin/vdirsyncer sync  2>&1
        # Your contacts directory goes here, obviously.
        cd /home/steven/.contacts
        git add .
        git commit -a -m "automated sync"
        git gc --auto --prune
```

## Related vcard

The scripts here presume the "filesystem" version where each contact is 
a separate vcard. 