package IM::Engine::Interface::AIM;
use Moose;
use Scalar::Util 'weaken';

extends 'IM::Engine::Interface';

has oscar => (
    is      => 'ro',
    isa     => 'Net::OSCAR',
    lazy    => 1,
    builder => '_build_oscar',
);

has '+user_class' => (
    default => 'IM::Engine::User::AIM',
);

sub _build_oscar {
    my $self = shift;

    my $oscar = Net::OSCAR->new;

    my $weakself = $self;
    $oscar->set_callback(sub {
        my (undef, $sender, $message, $is_away) = @_;

        my $incoming = IM::Engine::Incoming->new(
            sender  => $weakself->user_class->new(name => $sender),
            message => $message,
        );

        $weakself->received_message($incoming);
    });
    weaken($weakself);

    $oscar->signon($self->credentials);

    return $oscar;
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    $self->oscar->send_im($outgoing->user->name, $outgoing->message);
}

sub run {
    my $self = shift;
    while (1) {
        $self->oscar->do_one_loop;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
