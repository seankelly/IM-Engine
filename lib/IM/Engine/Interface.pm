package IM::Engine::Interface;
use Moose;

has credentials => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
