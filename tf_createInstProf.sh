#!/bin/bash -e

# since we are using params resource `net_conf` as an IN all the params are set
# automatically. $REGION, #VPC settings that are used in tfvars file

export ACTION=$1
export RES_REPO="ans_sec_ops"
export RES_AWS_CREDS="aws_creds"

export STATE_RES="inst_tf_state"
export TF_STATEFILE="terraform.tfstate"

export OUT_INST_PROF="inst_prof_name"

# get the path where gitRepo code is available
export RES_REPO_STATE=$(shipctl get_resource_state $RES_REPO)

# Now get AWS keys
export AWS_ACCESS_KEY_ID=$(shipctl get_integration_resource_field $RES_AWS_CREDS aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(shipctl get_integration_resource_field $RES_AWS_CREDS aws_secret_access_key)

set_context(){
  # This restores the terraform state file
  shipctl copy_resource_file_from_state $STATE_RES $TF_STATEFILE .

  # now setup the variables based on context
  # naming the file terraform.tfvars makes terraform automatically load it
  shipctl replace terraform.tfvars
}

destroy_changes() {
  echo "----------------  Destroy changes  -------------------"
  terraform destroy -force
}

apply_changes() {
  echo "----------------  Planning changes  -------------------"
  terraform plan

  echo "-----------------  Apply changes  ------------------"
  terraform apply

  #output AMI VPC
  shipctl post_resource_state $OUT_INST_PROF versionName \
    "Version created by build $BUILD_NUMBER"
  shipctl put_resource_state $OUT_INST_PROF INST_PROF_NAME \
    $(terraform output instance_profile_name)
}

main() {
  echo "----------------  Testing SSH  -------------------"
  eval `ssh-agent -s`
  ps -eaf | grep ssh
  which ssh-agent

  pushd $RES_REPO_STATE

  set_context

  if [ $ACTION = "create" ]; then
    apply_changes
  fi

  if [ $ACTION = "destroy" ]; then
    destroy_changes
  fi

  popd
}

main
