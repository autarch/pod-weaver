package Pod::Weaver::Weaver::Methods;
use Moose;
with 'Pod::Weaver::Role::Weaver';

use Moose::Autobox;

has command => (is => 'ro', isa => 'Str', required => 1, default => 'method');
has header  => (is => 'ro', isa => 'Str', required => 1, default => 'METHODS');

sub weave {
  my ($self) = @_;

  my @methods;

  my $input = $self->weaver->input_pod;
  for my $i (reverse (0 .. $input->length - 1)) {
    my $element = $input->[ $i ];
    next unless $element->type eq 'command'
            and $element->command eq $self->command;

    splice @$input, $i, 1;
    unshift @methods, $element;
  }

  $self->weaver->output_pod->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => $self->header,
      children => @methods->map(sub {
        Pod::Elemental::Element::Command->new({
          type     => 'command',
          command  => 'head2',
          content  => $_->content,
          children => scalar $_->children,
        })
      }),
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
