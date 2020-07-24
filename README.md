pplsearch
==========

# pplsearch: An addressbook searcher for use with a mess of vcards

![pplsearch logo](https://raw.githubusercontent.com/uriel1998/ppl_virdirsyncer_addysearch/master/pplsearch-open-graph.png "logo")

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
## 1. About 

I really liked [ppl](https://web.archive.org/web/20170610235714/http://ppladdressbook.org/) and the control it 
gave you over your contacts. I was thrilled to find [vdirsyncer](https://github.com/pimutils/vdirsyncer) 
and the way it can sync your contacts with multiple services. But I wanted a way to be able to 
quickly and easily search through my contacts for basic information and, if I wanted,  
to have a GUI to do it. 

As `ppl` is now defunct, this script has taken the place of accessing (though 
not *editing*) my addressbook quickly and easily with a GUI or TUI.

This is a complete overhaul from prior versions.

## 2. License

This project is licensed under the MIT License. For the full license, see `LICENSE`.

## 3. Prerequisites

All of these are available in Debian (and presumably Ubuntu) as packages:

`sudo apt install vdirsyncer rofi fzf zenity ripgrep`

* [zenity](https://help.gnome.org/users/zenity/stable/) or a drop-in replacement like [matedialog](https://github.com/mate-desktop/mate-dialogs) or 
[wenity](http://freecode.com/projects/wenity) for viewing GUI output
* [fzf](https://github.com/junegunn/fzf) - Provides TUI for selecting VCard
* [rofi](https://github.com/davatorium/rofi) - Provides GUI for selecting VCard
* [vdirsyncer](https://github.com/pimutils/vdirsyncer) with the "filesystem" option
* [ripgrep](https://github.com/BurntSushi/ripgrep) for faster grepping

Trust me, you want to check out `fzf`, `rofi`, and `ripgrep` anyhow.

## 4. Installation

Place `pplsearch` and `vcardreader` in the same directory somewhere in your PATH.  
If your VCards are somewhere other than `$HOME/.contacts/contacts` you will 
need to edit line 14 to reflect the location of your contacts.


## 5. Usage

`pplsearch [-h|-m|-c]`

* -h : Show a very basic help file
* -c : Run in cli/TUI mode 
* -m : Run in Mutt mode

Call `pplsearch` (from the command line, a launcher, Mutt, or an Openbox menu) 
and it will quickly give you a list of names (through `fzf` in the terminal, or 
using `rofi` on X. Select the name (and VCard) you want to use.

In GUI mode, `pplsearch` will use `zenity` to nicely display the results. In 
TUI mode, `pplsearch` will return the information to STDOUT.  In both cases, 
black and white emojis are used to make things look a bit better.

In Mutt mode, `pplsearch` will only return an email address, so can be used 
for address completion by Mutt. If there is more than one email address for 
that contact, it will use `fzf` again to let you choose the proper email.

If you do not have `vdirsyncer` set up, you'll have to get the vcards 
there some other way (say, exporting from your mail client).

## 6. VCardreader

Yes, it's another VCard reader. This one is in bash. 

It can be sourced to provide the function `read_vcard`. If sourced to provide 
this function, it expects the variable `$SelectedVcard` to point to the VCard 
you want to read. 

It can also be used as a standalone VCard reader by specifying the full path and 
filename of the VCard you wish to examine. For example,

`vcardreader /home/steven/.contacts/contacts/VCard_is_here.vcf`

## 7. VCardfixer

The `vcardfixer.sh` script is there to simply fix some small irregularities 
in individual vcards. Currently it handles the lack of the N: field (and 
properly swaps last and first names) and the lack of an END:VCARD field. 
It's a pretty simple bash script (though finding out that a rogue carriage 
return was causing me problems took forever), so if you have another field 
that's causing problems, you can fix it.

## 8. Tip

Make your contacts into a git repository!

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

## 9. TODO

* Reintroduce image display with GUI version
* Add in additional fields to the reader function (e.g. Title, Address)