if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

