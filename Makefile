VERSION := 0.0.1
NAME := huggingface-intro
REPO := cakiki

build-gpu: clean
	docker build -f dockerfiles/Dockerfile.tf.gpu -t ${REPO}/${NAME}-gpu:${VERSION} -t ${REPO}/${NAME}-gpu:latest .

build-cpu:
	docker build -f dockerfiles/Dockerfile.cpu -t ${REPO}/${NAME}-cpu:${VERSION} -t ${REPO}/${NAME}-cpu:latest .

run-gpu: build-gpu
	docker run --rm -it --network host --gpus all --env HF_HOME=/tf/cache/HF --mount type=bind,source=${PWD},target=/tf ${REPO}/${NAME}-gpu:${VERSION} && make -s clean

run-cpu: build-cpu
	docker run --rm -it --network host --env HF_HOME=/home/jovyan/work/cache/HF --mount type=bind,source=${PWD},target=/home/jovyan/work --workdir=/home/jovyan/work ${REPO}/${NAME}-cpu:${VERSION} jupyter notebook

elastic:
	docker run --rm -it --mount type=bind,source=${PWD}/data/ES,target=/usr/share/elasticsearch/data \
		--network host --memory=16g --env discovery.type=single-node \
		docker.elastic.co/elasticsearch/elasticsearch:8.1.3

clean:
	sudo chown -R 1000:1000 .

push-cpu: build-cpu
	docker push ${REPO}/${NAME}-cpu:${VERSION} && docker push ${REPO}/${NAME}-cpu:latest

push-gpu: build-gpu
	docker push ${REPO}/${NAME}-gpu:${VERSION} && docker push ${REPO}/${NAME}-gpu:latest
