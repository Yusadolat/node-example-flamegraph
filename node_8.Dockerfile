FROM node:8.16.1

WORKDIR /usr/src/app

RUN HOME=$(pwd) && \ 
    LINUX_VER=$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1) && \
    wget "https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$LINUX_VER.tar.xz"

# Run in a separate cmd so the wget can be cached in its own layer
RUN HOME=$(pwd) && \ 
    LINUX_VER=$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1) && \
    tar -xf "./linux-$LINUX_VER.tar.xz" && cd "linux-$LINUX_VER/tools/perf/" && \ 
    apt-get update && apt -y install flex bison && \ 
    make -C . && make install && \
    cd $HOME

RUN npm i -g stackvis

COPY package*.json ./

RUN npm install

COPY app.js container*.sh ./

VOLUME ["/out"]

EXPOSE 8080

ENTRYPOINT ["node", "--perf_basic_prof_only_functions", "app.js"]