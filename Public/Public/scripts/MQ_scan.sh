#/bin/sh

for env in ../../SIT/*; do
    echo $env
    cd $env
    ./env_check.sh -m 2>/dev/null
    echo
done

for env in ../../UAT/*; do
    echo $env
    cd $env
    ./env_check.sh -m 2>/dev/null
    echo
done

