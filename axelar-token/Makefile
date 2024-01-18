include .env
export

.PHONY: deps
deps:
	forge install --no-commit axelarnetwork/axelar-gmp-sdk-solidity openzeppelin/openzeppelin-contracts

.PHONY: help
help:
	@echo "\033[0;32mAvailable targets:\033[0m"
	@echo "deps               - Install Foundry dependencies"
	@echo "deploy-sender      - Deploy the token sender contract on Polygon Mumbai"
	@echo "deploy-handler     - Deploy the token handler contract on Filecoin Calibrationnet"
	@echo "deposit            - Deposit tokens into the subnet"

.PHONY: deploy-handler
deploy-handler: NETWORK := FILECOIN_CALIBRATION
deploy-handler:
	forge script ./script/DeployTokenHandler.s.sol \
		--rpc-url "${$(NETWORK)__RPC_URL}" \
		--broadcast \
		--skip-simulation

.PHONY: deploy-sender
deploy-sender: NETWORK := POLYGON_MUMBAI
deploy-sender:
	forge script ./script/DeployTokenSender.s.sol \
		--rpc-url "${$(NETWORK)__RPC_URL}" \
		--broadcast \
		--skip-simulation

.PHONY: deposit
deposit: NETWORK := POLYGON_MUMBAI
deposit:
	@echo "Please enter the details:"; \
	read -p "Beneficiary: " BENEFICIARY; \
  	read -p "Amount: " AMOUNT; \
	read -p "Symbol (as registered in Axelar): " SYMBOL; \
	read -p "Destination subnet root: " SUBNET_ROOT; \
	read -p "Destination subnet address: " SUBNET_ADDR; \
	export $$BENEFICIARY; export $$AMOUNT; export $$SYMBOL; export $$SUBNET_ROOT; export $$SUBNET_ADDR; \
	forge script ./script/Deposit.s.sol \
		--rpc-url "${$(NETWORK)__RPC_URL}" \
		--broadcast \
		--skip-simulation