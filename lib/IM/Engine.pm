package IM::Engine;
use Moose;
use Moose::Util::TypeConstraints;

use IM::Engine::Interface;

our $VERSION = '0.01';

with 'IM::Engine::HasPlugins';

has interface_args => (
    is       => 'ro',
    isa      => 'HashRef',
    init_arg => 'interface',
    required => 1,
);

has interface => (
    is       => 'ro',
    isa      => 'IM::Engine::Interface',
    handles  => ['run'],
    init_arg => undef,
    builder  => '_build_interface',
    lazy     => 1,
);

sub _build_interface {
    my $self = shift;

    my $interface = $self->interface_args
        or confess "You must provide 'interface' to " . blessed($self) . "->new";

    my $protocol = delete $interface->{protocol}
        or confess "Your IM::Engine::Interface definition must include the 'protocol' key.";

    if ($protocol !~ s{^\+}{}) {
        $protocol = join '::', 'IM', 'Engine', 'Interface', $protocol;
    }

    Class::MOP::load_class($protocol);

    return $protocol->new(
        %$interface,
        engine => $self,
    );
}

sub engine { shift }

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

__END__

=head1 NAME

IM::Engine - The HTTP::Engine of instant messaging

=head1 SYNOPSIS

    IM::Engine->new(
        interface => {
            protocol => 'AIM',
            credentials => {
                screenname => '...',
                password   => '...',
            },
            incoming_callback => sub {
                my $incoming = shift;

                my $message = $incoming->message;
                $message =~ tr[a-zA-Z][n-za-mN-ZA-M];

                return $incoming->reply($message);
            },
        },
    )->run;

=head1 DESCRIPTION


=head1 AUTHOR

Shawn M Moore, C<sartak@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

