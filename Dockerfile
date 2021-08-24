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
RUN sudo rm -rf $(pwd)/yay
RUN yay --noconfirm -S code-server
RUN mkdir -p $(pwd)/.config
VOLUME [ "/config" ]
RUN sudo ln -s /config $(pwd)/.config/
RUN sudo mv $(pwd)/.config/config $(pwd)/.config/code-server
RUN sudo mkdir -p /cert 
RUN sudo chown -R $USER:$USER /cert
VOLUME [ "/cert" ]
EXPOSE 8080 8080
RUN mkdir -p $(pwd)/cert
RUN sudo chown -R $USER $(pwd)
RUN echo sudo find /cert/ -type f -name \"*.crt\" -exec sudo cp {} $(pwd){} \\\; >> $(pwd)/run.sh
RUN echo sudo find /cert/ -type f -name \"*.key\" -exec sudo cp {} $(pwd){} \\\; >> $(pwd)/run.sh
RUN echo sudo chown -R $USER /home/$USER >> $(pwd)/run.sh
RUN echo code-server --bind-addr 0.0.0.0:8080 --cert ~/cert/*.crt --cert-key ~/cert/*.key >> $(pwd)/run.sh
RUN sudo chown -R $USER $(pwd)
RUN sudo chmod 755 $(pwd)/run.sh
CMD $(pwd)/run.sh
