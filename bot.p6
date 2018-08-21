use IRC::Client;
my $nick = 'p6bannerbot';
my $l := Lock.new;
my %seen is SetHash;
my %wait-list;

.run with IRC::Client.new:
  |(:password('pass.txt'.IO.slurp.trim) if 'pass.txt'.IO.e),
  :host<irc.freenode.net>, :channels<#perl6  #perl6-dev  #perl6-toolchain  #moarvm  #zofbot>, :debug, :$nick,
  # :host<localhost>, :channels<#perl6-redirect>, :debug, :nick<p6bot>,
plugins =>
  class :: does IRC::Client::Plugin {
    multi method irc-join ($e where .nick ne $nick && (.host.contains: '/' or .nick.starts-with: 'travis-ci')) {
        $e.irc.send-cmd: 'MODE', $e.channel, '+v', $e.nick;
        Nil
    }

    multi method irc-join ($e where .nick ne $nick) {
        $l.protect: { %wait-list{$e.nick} = now }

        %seen{$e.host} || Promise.in(1).then: {
          $l.protect: { %seen{$e.host}++ }
          $e.irc.send: :where($e.nick), :notice, text => qq{$e.nick(), Greetings! We're currently dealing with a massive spam attack and have to filter users who can connect. You will be allowed to talk (given +v) in 45 seconds. Do not attempt to send messages now.}
        }
        Promise.in(45).then: {
            $l.protect: {
                now - 20 > %wait-list{$e.nick}
                  and $e.irc.send-cmd: 'MODE', $e.channel, '+v', $e.nick;
                %wait-list{$e.nick}:delete;
            }
        }
        Nil
    }
    
    multi method irc-join ($e where .nick eq $nick) {
        $e.irc.send-cmd: 'CS', 'op', $e.channel;
        Nil
    }
    
    multi method irc-privmsg-channel ($e) {
        %wait-list{$e.nick} and $l.protect: { %wait-list{$e.nick} = now if %wait-list{$e.nick} }
        $.NEXT
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
