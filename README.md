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

## Related

The `vcardfixer.sh` script is there to simply fix some small irregularities 
in individual vcards so that `ppl` can handle them properly. Currently 
it handles the lack of the N: field (and properly swaps last and first 
names) and the lack of an END:VCARD field. It's a pretty simple bash 
script (though finding out that a rogue carriage return was causing me 
problems took forever), so if you have another field that's causing 
problems, you can fix it.

## Related vcard

The scripts here presume the "filesystem" version where each contact is 
a separate vcard. If you need one large vcard (such as for Claws mail) 
see the example conf. Since Claws can only read the vcard, this setup 
of syncing and conflict resolution from the cloud to individual vcards 
to big vcard works.
