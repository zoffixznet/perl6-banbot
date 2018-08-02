use IRC::Client;
my $nick = 'p6bannerbot';
.run with IRC::Client.new:
  |(:password('pass.txt'.IO.slurp) if 'pass.txt'.IO.e),
  :host<irc.freenode.net>, :channels<#perl6  #perl6-dev  #perl6-toolchain  #moarvm>, :debug, :$nick,
  # :host<localhost>, :channels<#perl6-redirect>, :debug, :nick<p6bot>,
plugins =>
  class {
    multi method irc-join ($e where .nick ne $nick && .host.starts-with: 'gateway/web/') {
        Promise.in(10).then: { $e.irc.send-cmd: 'MODE', $e.channel, '+v', $e.nick }
        Nil
    }

    multi method irc-join ($e where .nick ne $nick) {
        Promise.in(1).then: {
          $e.irc.send: :where($e.nick), :notice, text => qq{$e.nick(), Greetings! We're currently dealing with a massive spam attack and have to filter users who can connect. You will be allowed to talk in 10 seconds}
        }
        Promise.in(10).then: { $e.irc.send-cmd: 'MODE', $e.channel, '+v', $e.nick }
        Nil
    }


    # method irc-join ($e) {
    #     Promise.in(1).then: {
    #       $e.irc.send: :where($e.channel), text => qq{$e.nick(), Greetings! We're currently dealing with a massive spam attack and have to filter users who can connect. To join one of our channels, simply change your nick to end with `-p6` (e.g. "Joe" => "Joe-p6"), or register your nick (/msg NickServ help register), or use the Web-based interface to connect https://perl6.org/irc}
    #     }
    # }
    # method irc-privmsg-channel ($e where .Str.contains:
    #   'Hey, I thought you guys might be interested in this blog by freenode staff member Bryan') {
    #   # $e.irc.send-cmd: 'MODE', $e.channel, '+b', '*!*@' ~ $e.host ~ '$#zofbot-ban';
    #   $e.irc.send-cmd: 'KICK', $e.channel, $e.nick,
    #       'Automatic spam detection triggered';
    # }
  }
