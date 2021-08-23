FROM archlinux:latest
EXPOSE 80
EXPOSE 443
USER root
RUN pacman --noconfirm -Syu sudo vi vim base-devel go git zsh
RUN echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ARG USER=archcode
RUN useradd -mG root $USER
RUN ["mkdir", "-p", "$USER"]
RUN chown -R ${USER} /home/${USER}
USER ${USER}
WORKDIR "/home/$USER"
RUN git clone https://aur.archlinux.org/yay.git
WORKDIR "/home/$USER/yay"
RUN makepkg -Si && makepkg -i --noconfirm
RUN sh -c "$(curl -LsSf https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
WORKDIR "/home/$USER"
RUN sudo rm -rf /home/$USER/yay
RUN yay --noconfirm -S code-server
RUN mkdir -p /home/$USER/.config
VOLUME [ "/config" ]
RUN sudo ln -s /config /home/$USER/.config/
RUN sudo mv /home/$USER/.config/config /home/$USER/.config/code-server
RUN sudo chown -R $USER /home/$USER
EXPOSE 8080 8080
CMD ["code-server","--bind-addr","0.0.0.0:8080"]