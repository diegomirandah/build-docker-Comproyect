FROM ubuntu:18.04
#labels
LABEL maintainer="diego.miranda.h@gmail.com"
LABEL description="CPU-only version of OpenPose."
LABEL version="1.0"

ARG HOST_DB
ENV HOST_DB $HOST_DB
ARG PORT_DB
ENV PORT_DB $PORT_DB

RUN echo $HOST_DB $PORT_DB

#DEBIAN EN MODO NO INTERACTIVE
ENV DEBIAN_FRONTEND=noninteractive

#INSTALAR PAQUETES
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install wget apt-utils lsb-core cmake git -y && \
    apt-get install libopencv-dev -y

RUN apt-get install libasound-dev portaudio19-dev libportaudio2 libportaudiocpp0 -y
RUN apt-get install python3.6 python3.6-dev python3-pip -y

#CLONAR OPENPOSE
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
WORKDIR openpose
#RUN git checkout caa794cf81bed53b9e114299b715a6d972097b5b
WORKDIR scripts/ubuntu
RUN sed -i 's/\<sudo -H\>//g' install_deps.sh; \
   sed -i 's/\<sudo\>//g' install_deps.sh; \
   sed -i 's/\<easy_install pip\>//g' install_deps.sh; \
   sync; sleep 1; bash install_deps.sh
WORKDIR /openpose/build

#COMPILAR OPENPOSE
RUN cmake -DBUILD_PYTHON:Bool=ON -DGPU_MODE:String=CPU_ONLY -DBUILD_EXAMPLES:Bool=ON -DDOWNLOAD_FACE_MODEL:Bool=OFF -DDOWNLOAD_HAND_MODEL:Bool=OFF ..
RUN make -j

#MONTAR SERVIDOR FLASK
WORKDIR /openpose
RUN echo hol5
RUN git clone https://github.com/diegomirandah/ComProyect-Server server
WORKDIR /openpose/server
COPY ./requirements.txt /openpose/server/requirements.txt
RUN pip3 install -r requirements.txt

#ELIMINAR PAQUETES PARA COMPILAR
RUN apt-get remove wget unzip cmake git build-essential -y && apt-get autoremove -y

#DEPLY APP
ENTRYPOINT python3 run.py --host_db=${HOST_DB} --port_db=${PORT_DB} --interpreter python3

#CMD run.py --host_db = $HOST_DB --port_db = $PORT_DB


#WORKDIR /openpose

#ENTRYPOINT ["build/examples/openpose/openpose.bin"]

#CMD ["--help"]