build-docker: 
	aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 629923658207.dkr.ecr.eu-west-1.amazonaws.com
	docker build -t clamav .
	docker tag clamav:latest 629923658207.dkr.ecr.eu-west-1.amazonaws.com/clamav:${TAG}
	docker push 629923658207.dkr.ecr.eu-west-1.amazonaws.com/clamav:${TAG}


deploy-tf: 
