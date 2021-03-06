# Macroses
########################################################################################################################
AWS_PROFILE ?= $(NAMESPACE)-$(ENV_BASE)
AWS_USER ?= $(shell aws --profile=$(AWS_PROFILE) iam get-user | $(JQ) -r ".User.UserName")
AWS_ACCOUNT ?= $(shell [ -f ~/.aws/credentials ] && $(AWS) --profile=$(AWS_PROFILE) sts get-caller-identity | $(JQ) -r '.Account' || echo "nil" )
AWS_DEV_ENV_NAME ?= $(shell aws --profile=$(AWS_PROFILE) iam list-user-tags --user-name $(AWS_USER) | ( $(JQ) -e -r '.Tags[] | select(.Key == "devEnvironmentName").Value'))
AWS ?= $(DOCKER) run -v $(HOME)/.aws/:/root/.aws -i amazon/aws-cli:2.0.8
# Tasks
########################################################################################################################
aws.debug: ## Show environment information for debug purposes
	@echo "\033[32m=== AWS Environment Info ===\033[0m"
	@echo "\033[36mENV\033[0m: $(ENV)"
	@echo "\033[36mAWS_DEV_ENV_NAME\033[0m: $(AWS_DEV_ENV_NAME) (set devEnvironmentName here https://console.aws.amazon.com/iam/home?region=us-east-1#/users/$(AWS_USER)?section=tags)"
	@echo "\033[36mAWS_ACCOUNT\033[0m: $(AWS_ACCOUNT)"
	@echo "\033[36mAWS_PROFILE\033[0m: $(AWS_PROFILE)"
	@echo "\033[36mAWS_USER\033[0m: $(AWS_USER)"
	@echo "\033[36mTAG\033[0m: $(TAG)"

aws.profile:
	$(shell mkdir -p ~/.aws && echo "[$(AWS_PROFILE)]\naws_access_key_id = $(AWS_ACCESS_KEY_ID)\naws_secret_access_key = $(AWS_SECRET_ACCESS_KEY)\nregion = $(AWS_REGION)" >> ~/.aws/credentials)


# Dependencies
########################################################################################################################
# Ensures aws toolchain is installed
aws:
ifeq (, $(AWS))
	$(error "aws cli toolchain is not installed or incorrectly configured.")
endif
