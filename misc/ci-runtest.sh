#!/bin/sh

ODIR=$PWD/mybin
export PATH=$ODIR:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/musl/bin:$HOME/bin

pwd

# Check for required tools
for cmd in host awk grep sed cut
do
  type $cmd >/dev/null
done

which host
host jasan.tk

echo "COVERAGE is $COVERAGE"
if [ "x1" = "x$COVERAGE" ] ; then
	$GEM_HOME/wrappers/bashcov -- tests/test-shell.sh
else
	tests/test-shell.sh || DEBUG=1 tests/test-shell.sh
fi
