FROM i386/alpine:3.12

# VNC Server password
ARG PW=a

RUN apk --no-cache add sudo bash supervisor x11vnc shadow firefox-esr xvfb xvfb-run \
	exo xfce4-whiskermenu-plugin thunar numix-themes-xfwm4 xfce4-panel xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xsetroot \
	ttf-dejavu numix-themes-gtk2 adwaita-icon-theme \
	wine freetype

ENV GECKO_VERSION=2.47 \
	MONO_VERSION=5.1.0
ENV GECKO_FILE=wine_gecko-${GECKO_VERSION}-x86.msi \
	MONO_FILE=wine-mono-${MONO_VERSION}-x86.msi \
	GECKO_MD5=5ebc4ec71c92b3db3d84b334a1db385d \
	MONO_MD5=1ac322c9758404d62d0acd0f673556b3

RUN apk add --no-cache --virtual .build-deps \
    ca-certificates \
    && x11vnc -storepasswd ${PW} /etc/vncpw \
	&& chmod 400 /etc/vncpw \
	&& sed -i 's|root:x:0:0:root:/root:/bin/ash|root:x:0:0:root:/root:/bin/bash|g' /etc/passwd \
	&& cd /tmp \
	&& wget https://dl.winehq.org/wine/wine-gecko/${GECKO_VERSION}/${GECKO_FILE} \
	&& wget https://dl.winehq.org/wine/wine-mono/${MONO_VERSION}/${MONO_FILE} \
	&& echo "$GECKO_MD5 *${GECKO_FILE}" | md5sum -c - \
	&& echo "$MONO_MD5 *${MONO_FILE}" | md5sum -c - \
	&& wine msiexec /i ${GECKO_FILE} \
	&& wine msiexec /i ${MONO_FILE} \
	&& apk del .build-deps \
	&& rm /tmp/wine*

COPY supervisord.conf /etc/supervisor/conf.d/

EXPOSE 5900
WORKDIR /root

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
