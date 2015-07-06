#!/bin/sh

set -ue

result()
{
    err=$?
    echo

    if [ $err -eq 0 ]; then
        echo "Pass :)"
    else
        cat "$logfile"

        echo "Fail :("
    fi

    exit $err
}

trap result EXIT

cd "`dirname "$0"`"
dir="`pwd`"

rm -rf /tmp/_test_vim-sesspit
mkdir -p /tmp/_test_vim-sesspit
cd /tmp/_test_vim-sesspit

cat <<EOF > testrc.vim
set nocompatible
let &runtimepath="$dir"
try
        source $dir/plugin/sesspit.vim
catch
        echo v:exception
        cquit
endtry
EOF

describe()
{
    echo "$@"
}

it()
{
    rm -f "$logfile"
    echo "    $@"
}

logfile="/tmp/_test_vim-sesspit/lastrun.log"


run()
{
    set +e
    out=`vim "-V20$logfile" -u "/tmp/_test_vim-sesspit/testrc.vim" "+source $dir/plugin/sesspit.vim" "$@" "+qall" 2>&1`
    err=$?
    set -e

    out=`echo "$out" | grep -Ev "^Vim: Warning: (In|Out)put is not to a terminal$"`

    if [ $err -ne 0 ]; then
        echo "$out"
    fi

    return $err
}

cleanup()
{
    find /tmp/_test_vim-sesspit/ \! -wholename /tmp/_test_vim-sesspit/ -and \! -name testrc.vim -and \! -name lastrun.log -exec rm -rf {} +
}

describe "SessPit"
default_marker=".git"
default_sessfile=".vimsession~"

it "should have a SessPit command"
run '+if !exists(":SessPit") | cquit | endif'

it "should create a session file when the command is executed"
run +SessPit
[ -e $default_sessfile ]
cleanup

it "should create a session file in a project directory rather than the current one"
mkdir .git foo
cd foo
run +SessPit
cd ..
[ ! -e foo/$default_sessfile ]
[ -e $default_sessfile ]
cleanup

it "should allow setting a new marker"
marker="TEST_PROJECT_MARKER"
mkdir foo
touch $marker
cd foo
run "+call sesspit#set_project_markers(\"$marker\")" +SessPit
cd ..
[ -e $default_sessfile ]
cleanup

it "should allow setting a new session file name"
name="TEST_SESSION_NAME"
run "+call sesspit#set_filename(\"$name\")" +SessPit
[ -e $name ]
cleanup

it "should allow setting session options"
run "+call sesspit#set_sessionoptions(\"buffers,options\")" +SessPit
[ -e $default_sessfile ]
grep -q '^set sessionoptions=buffers,options$' $default_sessfile
cleanup
