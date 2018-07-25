use IRC::Client;
.run with IRC::Client.new: :host<irc.freenode.net>, :channels<#perl6>, :debug, :nick<p6bannerbot>,
plugins =>
  class {
    method irc-privmsg-channel ($e where .Str.contains:
      'Hey, I thought you guys might be interested in this blog by freenode staff member Bryan') {
      # $e.irc.send-cmd: 'MODE', $e.channel, '+b', '*!*@' ~ $e.host ~ '$#zofbot-ban';
      $e.irc.send-cmd: 'KICK', $e.channel, $e.nick,
          'Automatic spam detection triggered';
    }
  }
