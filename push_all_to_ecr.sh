#!/usr/bin/env bash
set -e
AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_PREFIX="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
SERVICES=(user-service course-service content-service event-producer-service notification-service analytics-api-service)

# login
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ECR_PREFIX}

for svc in "${SERVICES[@]}"; do
  repo="${svc}"
  # create repo if not exists
  if ! aws ecr describe-repositories --repository-names "${repo}" --region $AWS_REGION >/dev/null 2>&1; then
    aws ecr create-repository --repository-name "${repo}" --region $AWS_REGION || true
  fi

  # build, tag, push
  docker build -t ${svc}:latest ./microservices/${svc}
  docker tag ${svc}:latest ${ECR_PREFIX}/${svc}:latest
  docker push ${ECR_PREFIX}/${svc}:latest
  echo "pushed ${ECR_PREFIX}/${svc}:latest"
done
