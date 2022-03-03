#!/bin/bash

trap '
  trap - INT # restore default INT handler
  kill -s INT "$$"
' INT

NUM=4000

while :
do
  TRY=0
  FAILS=0

  echo -n $NUM

  while [ $TRY -le 5 ];
  do
    timeout 5 curl -s "https://do-bug-test-bqjle.ondigitalocean.app/?length=$NUM" 1> /dev/null
    EXIT_STATUS=$?
    if [ $EXIT_STATUS -eq 124 ]; then
      ((FAILS++))
    fi

    ((TRY++))
  done

  echo -ne "\\r\\r\\r\\r\\r\\r"

  ((NUM++))

  if [ $FAILS -gt 2 ]; then
    echo "$FAILS occurred with $NUM characters."
    break
  fi
done