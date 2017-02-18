#!/bin/sh -e
##############################################################################
#
# Copyright 2015 spf-tools team (see AUTHORS)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
##############################################################################
#
# Usage: ./despf <domain_with_SPF_TXT_record>

test -n "$DEBUG" && set -x

# Check for required tools
for cmd in host awk grep sed cut
do
  type $cmd >/dev/null
done

a="/$0"; a=${a%/*}; a=${a#/}; a=${a:-.}; BINDIR=$(cd $a; pwd)
. $BINDIR/include/global.inc.sh
. $BINDIR/include/despf.inc.sh

# Read DNS_TIMEOUT if spf-toolsrc is present
test -r $SPFTRC && . $SPFTRC

usage() {
    cat <<-EOF
	Usage: despf.sh [OPTION]... [DOMAIN]...
	Decompose SPF records of a DOMAIN, sort and unique them.
	DOMAIN may be specified in an environment variable.

	Available options:
	  -s DOMAIN[:DOMAIN...]      skip domains, i.e. leave include
	                             without decomposition
	  -t N                       set DNS timeout to N seconds
	  -h                         display this help and exit
	  -u                         unordered output
	EOF
    exit 1
}

DESPF_SORT_BIN="sort -u"
domain=${DOMAIN:-'spf-orig.jasan.tk'}
test -n "$domain" -o "$#" -gt 0 || usage
while getopts "ut:s:h-" opt; do
  case $opt in
    t) test -n "$OPTARG" && DNS_TIMEOUT=$OPTARG;;
    s) test -n "$OPTARG" && DESPF_SKIP_DOMAINS=$OPTARG;;
    u) DESPF_SORT_BIN="cat";;
    *) usage;;
  esac
done
shift $((OPTIND-1))

# Domains specified as command line parameters override DOMAIN
test -z "$*" || domain="$*"

loopfile=$(mktemp /tmp/despf-loop-XXXXXXX)
echo random-non-match-tdaoeinthaonetuhanotehu > $loopfile
trap "cleanup $loopfile; exit 1;" INT QUIT

despfit "$domain" $loopfile | grep . || { cleanup $loopfile; exit 1; }
cleanup $loopfile
