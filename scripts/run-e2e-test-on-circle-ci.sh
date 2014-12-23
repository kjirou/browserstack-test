#!/bin/sh

#
# CircleCI 上で E2E テストを実行する
#
# Ref) https://circleci.com/docs/nightly-builds
#

_usage="usage: $0 [-b branch_name] [-t circle_token]"
_branch=''
_circle_token=''

while getopts 'b:t:' flag; do
  case $flag in
    b)
      _branch="$OPTARG";
      ;;
    t)
      _circle_token="$OPTARG";
      ;;
    \?)
      option_error=1;
      break
      ;;
  esac
done
shift `expr $OPTIND - 1`
if [ $option_error ]; then
  echo >&2 'Invalid option(s)'
  echo >&2 $_usage
  exit 1
fi

if [ "$_branch" = '' ]; then
  _branch='master'
fi
if [ "$_circle_token" = '' ]; then
  # Created by:
  # 1. https://circleci.com/gh/{GitHub-username}/{GitHub-project}/edit#api
  #    e.g. https://circleci.com/gh/kjirou/browserstack-test/edit#api
  # 2. Choice "All" status
  # 3. Click "Create token"
  _circle_token='90df5528a08567f02dbe0b76b892be4b10a8c00d'
fi

trigger_build_url=https://circleci.com/api/v1/project/kjirou/browserstack-test/tree/${_branch}?circle-token=${_circle_token}
echo $trigger_build_url

post_data=$(cat <<EOF
{
  "build_parameters": {
    "SHOULD_NOT_RUN_DEFAULT_TEST": "true",
    "SHOULD_RUN_E2E_TEST": "true"
  }
}
EOF)

curl \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data "${post_data}" \
--request POST ${trigger_build_url}
