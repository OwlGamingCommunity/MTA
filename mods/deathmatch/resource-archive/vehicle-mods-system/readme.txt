This system is for loading vehicle mods without having to modify san andreas files, it does this by using MTA's loading functions instead.

To add a vehicle to be replaced edit mods.txt
which should look something like this

<mods>
    <mod />
</mods>

Adding a mod will be pretty simple here, just change it to this

<mods>
    <mod DFF="changeme.dff" TXD="changeme.txd" model="changeme" />
</mods>

where
DFF is the full path to the DFF file 
TXD is the full path to the TXD file
model is the model id this is replacing

or your file may look like this

<mods>
    <mod TXD="TXD.TXD" DFF="DFF.DFF" model="model" />
</mods>

in which case add a line
like forth
<mods>
    <mod TXD="TXD.TXD" DFF="DFF.DFF" model="model" />
    <mod TXD="changeme.txd" DFF="changeme.dff" model="changeme" />
</mods>

where
DFF is the full path to the DFF file 
TXD is the full path to the TXD file
model is the model id this is replacing

Note everything is case sensative
so
<mod txd="changeme.txd" dff="changeme.dff" MODEL="changeme" />
will not work

Quick example
To replace the enforcer use this line

<mod txd="enforcer.txd" dff="enforcer.dff" MODEL="427" />

assuming the enforcer.txd isn't in a folder inside vehicle-mods-system if it is read below.

Folders:

if you wish to use folders (its advised) then when editing the txd and dff part of the line from changeme you will need to specify the directory like so

Say you have enforcer.txd and enforcer.dff in a folder mods


<mod TXD="mods/enforcer.txd" DFF="mods/enforcer.dff" model="427" />

is the line you would use