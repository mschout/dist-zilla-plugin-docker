package Dist::Zilla::Plugin::Docker::DockerClient;
# ABSTRACT: Internal Use Only, do not use!

use strict;
use warnings;

use Moose;

has docker_tag => (is => 'ro', isa => 'Str', required => 1);

sub build_image {
  my ($self, $dir, $dockerfile) = @_;

  system('docker', 'build',
    '-f' => $dockerfile,
    '-t' => $self->docker_tag,
    $dir
  ) and Carp::croak "docker build failed: $@";
}

sub push_image {
  my $self = shift;

  system('docker', 'push', $self->docker_tag)
    and Carp::croak "docker build failed: $@";
}

1;

__END__

=for Pod::Coverage
- build_image
- push_image

=cut
