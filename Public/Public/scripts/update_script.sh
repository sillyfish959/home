#/bin/sh

if [ $# -eq 0 ]; then
    echo sample: ./update_script.sh ./env_check.sh
    exit 0
fi

for env in ../../SIT/*; do
    cp $1 $env/
    echo cp $1 $env/
done

for env in ../../UAT/*; do
    cp $1 $env/
    echo cp $1 $env/
done

for env in ../../PROD/*; do
    cp $1 $env/
    echo cp $1 $env/
done

