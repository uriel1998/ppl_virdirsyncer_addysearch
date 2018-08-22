pplsearch
==========

# pplsearch: An addressbook searcher for use with ppl, vdirsyncer, and a mess of vcards

I really like [ppl](https://hnrysmth.github.io/ppl/) and the control it 
can give you over your contacts. I was thrilled to find [vdirsyncer](https://github.com/pimutils/vdirsyncer) 
and the way it can sync your contacts. But I wanted a way to be able to 
quickly and easily search through my contacts for basic information and 
to have a GUI to do it. So, zenity to the rescue.

## Requires

* [zenity](https://help.gnome.org/users/zenity/stable/) or a replacement like [matedialog](https://github.com/mate-desktop/mate-dialogs) or [wenity](http://freecode.com/projects/wenity).

### Strongly encouraged

* [vdirsyncer](https://github.com/pimutils/vdirsyncer) with the "filesystem" option
* [ppl](https://hnrysmth.github.io/ppl/) 

## Usage

Call the script (from the command line, a launcher, or an Openbox menu) 
and it will search for any string in a directory full of vcards. If ppl 
is installed, it will use the ppl configuration file to determine where 
to search, otherwise it uses the current directory. 

If no matches are available, you'll be told, otherwise you will be able 
to select from a list of full names (or given the single match if that's 
the case). Then the full info of the person will be presented to you.

If you do not have ppl installed, this will *work*, thanks to grep and 
sed, but the final output isn't quite as pretty.

If you do not have vdirsyncer set up, you'll have to get the vcards 
there some other way (say, exporting from your mail client).
