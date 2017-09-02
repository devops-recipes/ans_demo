#!/bin/bash -e
set -o pipefail

export CURR_JOB="build_ecs_ami"
export RES_REPO="ans_sec_ops"
export RES_VPC_AMI="ami_infra_state"
export RES_AWS_CREDS="aws_creds"
export OUT_AMI_SEC_APPRD="ami_sec_approved"

export RES_REPO_STATE=$(shipctl get_resource_state $RES_REPO)

# Now get AWS keys
export AWS_ACCESS_KEY_ID=$(shipctl get_integration_resource_field $RES_AWS_CREDS aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(shipctl get_integration_resource_field $RES_AWS_CREDS aws_secret_access_key)

set_context(){
  # now setup the variables based on context
  pushd $(shipctl get_resource_meta $RES_VPC_AMI)
  export AMI_VPC_ID=$(cat version.json | jq -r '.'version.propertyBag.VPC_ID)
  export AMI_PUBLIC_SN_ID=$(cat version.json | jq -r '.'version.propertyBag.VPC_SUBNET_ID)
  export AMI_PUBLIC_SG_ID=$(cat version.json | jq -r '.'version.propertyBag.VPC_SG_ID)
  popd

  shipctl replace pk_vars.json
}

build_ecs_ami() {
  echo "validating AMI template"
  echo "-----------------------------------"
  packer validate pk_baseAMI.json
  echo "building AMI"
  echo "-----------------------------------"

  packer build -var-file=pk_vars.json pk_baseAMI.json

  AMI_ID=$(shipctl get_json_value manifest.json builds[0].artifact_id | cut -d':' -f 2)

  # create version for ami param
  shipctl post_resource_state $CURR_JOB versionName $AMI_ID
  shipctl post_resource_state $OUT_AMI_SEC_APPRD versionName $AMI_ID
}

main() {
  eval `ssh-agent -s`
  which ssh-agent

  pushd "$RES_REPO_STATE"
  set_context
  build_ecs_ami
  popd
}

main
