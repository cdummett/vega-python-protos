include .env
export

EXTERN_DIR := "./extern"

all: protos test

protos:
	@if [ ! -d ./extern/ ]; then mkdir ./extern/; fi
	@echo "Downloading Git dependencies into " ${EXTERN_DIR}
	@echo "Downloading Vega"
	@if [ ! -d ./extern/vega ]; then mkdir ./extern/vega; git clone https://github.com/vegaprotocol/vega ${EXTERN_DIR}/vega; fi
ifneq (${VEGA_TAG},develop)
	@git -C ${EXTERN_DIR}/vega pull; git -C ${EXTERN_DIR}/vega checkout ${VEGA_TAG}
else
	@git -C ${EXTERN_DIR}/vega checkout develop; git -C ${EXTERN_DIR}/vega pull
endif
	@rm -rf ./vega_python_protos/protos
	@mkdir ./vega_python_protos/protos
	@buf generate extern/vega/protos/sources --template ./vega_python_protos/buf.gen.yaml
	@GENERATED_DIR=./vega_python_protos/protos vega_python_protos/post-generate.sh
	@black .

test:
	@env PYTHONPATH=. pytest tests
