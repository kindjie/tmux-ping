# Tmux Ping Status

Tmux plugin that allows displaying an average ping latency in the status line.
This plugin is heavily influenced by 
[Tmux online status](https://github.com/tmux-plugins/tmux-online-status) plugin.

### Usage

Add `#{ping}` format string to your existing `status-right` or `status-left` 
tmux option in the `.tmux.conf` file.

Example:

    set -g status-right "Ping: #{ping} #[fg=white]| %Y-%m-%d %I:%M"

![example](/screenshots/example.png)

### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'ayzenquwe/tmux-ping'

Hit `prefix + I` to fetch the plugin and source it.

### Manual Installation

Clone the repo:

    $ git clone https://github.com/ayzenquwe/tmux-ping ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/ping.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

### Implementation Details
The main technical difference from Tmux online status plugin is that the ping 
command is executed in background, and doesn't interfere with the status line
update process. If Tmux updates the status line and a previous ping command 
is not finished (due to big latencies), then a cached value will be used.

### License

[MIT](LICENSE.md)
