
FROM ubuntu:focal-20210723

ARG BRANCH=release

COPY ./.docker/scripts/entrypoint.sh /root/

RUN apt-get update && \
    apt-get install -y wget libatomic1 libc-bin && \
    mkdir -p /opt/altv/modules && \
    mkdir -p /opt/altv/resources && \
    mkdir -p /opt/altv/extra-resources && \
    mkdir -p /opt/altv/data && \
    wget --no-cache -q -O /opt/altv/altv-server https://cdn.altv.mp/server/${BRANCH}/x64_linux/altv-server && \
    wget --no-cache -q -O /opt/altv/data/vehmodels.bin https://cdn.altv.mp/server/${BRANCH}/x64_linux/data/vehmodels.bin && \
    wget --no-cache -q -O /opt/altv/data/vehmods.bin https://cdn.altv.mp/server/${BRANCH}/x64_linux/data/vehmods.bin && \
    wget --no-cache -q -O /opt/altv/data/clothes.bin https://cdn.altv.mp/server/${BRANCH}/x64_linux/data/clothes.bin && \
    chmod +x /opt/altv/altv-server /root/entrypoint.sh && \
    apt-get purge -y wget && \
    apt autoremove -y && \
    apt-get clean

######
# Install JS Module
######
RUN apt-get install -y wget jq && \
    mkdir -p /opt/altv/modules/js-module/ && \
    wget --no-cache -q -O /opt/altv/modules/js-module/libnode.so.83 https://cdn.altv.mp/js-module/${BRANCH}/x64_linux/modules/js-module/libnode.so.83 && \
    wget --no-cache -q -O /opt/altv/modules/js-module/libjs-module.so https://cdn.altv.mp/js-module/${BRANCH}/x64_linux/modules/js-module/libjs-module.so && \
    apt-get purge -y wget jq && \
    apt autoremove -y && \
    apt-get clean

######
# Install .NET 6 Module
######
RUN apt-get install -y wget gnupg && \
    # install dotnet runtime(s)
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get -y install apt-transport-https dotnet-runtime-6.0 && \
    # install altV module
    wget --no-cache -q -O /opt/altv/modules/libcsharp-module.so https://cdn.altv.mp/coreclr-module/${BRANCH}/x64_linux/modules/libcsharp-module.so && \
    mkdir -p /usr/share/dotnet/host/fxr/ && \
    wget --no-cache -q -O /opt/altv/AltV.Net.Host.dll https://cdn.altv.mp/coreclr-module/${BRANCH}/x64_linux/AltV.Net.Host.dll && \
    # remove unused tools
    apt-get purge -y wget gnupg && \
    apt autoremove -y && \
    apt-get clean
	

WORKDIR /opt/altv/

######
# Install some resources
######
COPY ./.docker/files/package.json /opt/altv/
SHELL ["/bin/bash", "-c"]
RUN apt-get install -y wget git && \
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
    source ~/.nvm/nvm.sh h && \
    nvm install 16 && \
    nvm use 16 && \
    npm install axios && \
    npm install cors && \
    npm install discord.js && \
    npm install dotenv && \
    npm install download && \
    npm install express && \
    npm install sjcl && \
    git -C /opt/altv/resources clone https://github.com/Stuyk/altv-discord-auth && \
    git -C /opt/altv/resources clone https://github.com/Dav-Renz/altV_freeroam && \
    git -C /opt/altv/resources clone https://github.com/altmp/altv-example-resources && \
    cp -r /opt/altv/resources/altv-example-resources/chat/ /opt/altv/resources/chat/ && \
    cp -r /opt/altv/resources/altv-example-resources/freeroam/ /opt/altv/resources/freeroam/ && \
    apt-get purge -y wget git && \
    apt autoremove -y && \
    apt-get clean


# Meant are the default values provided by the entrypoint script.
# Of course you can change the port as you like by using the
# environment variable "ALTV_SERVER_PORT".
EXPOSE 7788/udp
EXPOSE 7788/tcp

ENTRYPOINT [ "/root/entrypoint.sh" ]
