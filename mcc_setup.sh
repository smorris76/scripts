#!/bin/bash
export cmds=$HOME/tmp/commands
alias deploy1='clogin -x $cmds cfr01-$pop.hwng.net'
alias deploy2='clogin -x $cmds cfr02-$pop.hwng.net'
alias rdiff='diff -u ~/tmp/$pop-$peer-pre ~/tmp/$pop-$peer-post'
alias build='python3 ~/src/geobgp/cfr_config/geobgp_cfr_build.py -p $pop'
rcpoint ()
{
    clogin -c "configure checkpoint save $1" $2
}
rsnap ()
{
    clogin -c "show ip bgp neigh $2 adv" cfr01-$pop.hwng.net > ~/tmp/$pop-$2-$1
}
