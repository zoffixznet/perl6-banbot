use IRC::Client;
.run with IRC::Client.new:
  # :host<irc.freenode.net>, :channels<#perl6>, :debug, :nick<p6bannerbot>,
  :host<localhost>, :channels<#perl6-redirect>, :debug, :nick<p6bot>,
plugins =>
  class {
    method irc-join ($e) {
        Promise.in(1).then: {
          $e.irc.send: :where($e.channel), text => qq{$e.nick(), Greetings! We're currently dealing with a massive spam attack and have to filter users who can connect. To join one of our channels, simply change your nick to end with `-p6` (e.g. "Joe" => "Joe-p6"), or register your nick (/msg NickServ help register), or use the Web-based interface to connect https://perl6.org/irc}
        }
    }
    # method irc-privmsg-channel ($e where .Str.contains:
    #   'Hey, I thought you guys might be interested in this blog by freenode staff member Bryan') {
    #   # $e.irc.send-cmd: 'MODE', $e.channel, '+b', '*!*@' ~ $e.host ~ '$#zofbot-ban';
    #   $e.irc.send-cmd: 'KICK', $e.channel, $e.nick,
    #       'Automatic spam detection triggered';
    # }
  }
