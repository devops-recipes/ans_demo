#!/bin/bash -e

export REL_RES=$1
export OUT_PARAM_RES=$2

export REL_RES_UP=$(echo $REL_RES | awk '{print toupper($0)}')
export REL_RES_VER_NAME=$(eval echo "$"$REL_RES_UP"_VERSIONNAME") # contains current release

set_context(){
  echo "REL_RES=$REL_RES"
  echo "OUT_PARAM_RES=$OUT_PARAM_RES"

  echo "REL_RES_UP=$REL_RES_UP"
  echo "REL_RES_VER_NAME=$REL_RES_VER_NAME"
}

write_param_version(){
    #this is to get the ami from output
    echo versionName=$REL_RES_VER_NAME > "$JOB_STATE/$OUT_PARAM_RES.env"
    echo RELEASE_VER_NUMBER=$REL_RES_VER_NAME >> "$JOB_STATE/$OUT_PARAM_RES.env"
}

main() {
 set_context
 write_param_version
}

main
