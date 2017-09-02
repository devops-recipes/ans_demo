#!/bin/bash -e

export STATE_RES=$1

export RES_REPO="ans_sec_ops"
export RES_REPO_STATE=$(shipctl get_resource_state $RES_REPO)

export NEW_TF_STATEFILE="$RES_REPO_STATE/terraform.tfstate"

main() {
  shipctl refresh_file_to_out_path $NEW_TF_STATEFILE $STATE_RES
}

main
