Install Tools and Packages
==========================

1. Install Ubuntu from bootable key
2. Sync Firefox and install extensions (including Bitwarden)
3. Install Synology and sync folders
4. Install snap packages:
    ```
	sudo snap install discord
    ```
5. Install Ubuntu apt packages:
    5.1 Install Signal key (see https://signal.org/download/linux/):
        ```
        wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
        cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
        ```
    5.2 Add Signal repo to sources (see https://signal.org/download/linux/):
        ```
        wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources
        cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
        ```
    5.3 Add fish repo to sources:
        ```
    	sudo apt-add-repository ppa:fish-shell/release-4
        ```
    5.4 Update sources and install everything
        ```
    	sudo apt update
    	sudo apt install eog curl git fish tmux signal-desktop chromium-browser libreoffice evince texlive-full
        ```
6. Install Neovim
    ```
	cd ~
	curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
	chmod u+x nvim-linux-x86_64.appimage
    ln -s ~/nvim-linux-x86_64.appimage ~/.local/bin/nvim
    command -v nvim
    ```
7. Install dotfiles
8. Improvements:
    - install language server in nvim


Set up hibernate
================
1. Turn off Secure Boot in the BIOS
2. Create a 16G swap file:
    ```
	sudo swapoff /swap.img
	sudo rm /swap.img
	sudo fallocate -l 16G /swap.img
	sudo chmod 600 /swap.img
	sudo mkswap /swap.img
	sudo swapon /swap.img
	grep swap /etc/fstab
    ```
3. Add resume= and resume_offset= on the kernel command line:
	3.1 Find the filesystem UUID:
        ```
		findmnt -no UUID -T /swap.img
        ```
	3.2 Find the offset: find the first extent row (the one beginning 0:) and take the first number in the physical_offset column, the one before the ..
        ```
		sudo filefrag -v /swap.img | head -5
        ```
	3.3 Add them to the kernel command line. Edit `/etc/default/grub` and append to the 
        `GRUB_CMDLINE_LINUX_DEFAULT` line:
        ```
		resume=UUID=<your-uuid> resume_offset=<your-offset>
        ```
4. Configure `dracut` to include the resume module in the `initramfs`.
    ```
	sudo cp /boot/initrd.img-$(uname -r) /boot/initrd.img-$(uname -r).bak-manual
	echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/90-resume.conf
	sudo update-initramfs -u
    ```
5. Configuring laptop lid and sleep behavior settings.
	5.1 Set lid close behavior to suspend then hibernate:
        ```
		sudo mkdir -p /etc/systemd/logind.conf.d
		sudo tee /etc/systemd/logind.conf.d/lid.conf <<'EOF'
		[Login]
		HandleLidSwitch=suspend-then-hibernate
		HandleLidSwitchExternalPower=suspend-then-hibernate
		EOF
        ```
	5.2 Set how long it suspends before hibernating:
        ```
		sudo mkdir -p /etc/systemd/sleep.conf.d
		sudo tee /etc/systemd/sleep.conf.d/delay.conf <<'EOF'
		[Sleep]
		HibernateDelaySec=1h
		EOF
        ```
