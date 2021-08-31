package Dist::Zilla::Plugin::Docker;
# ABSTRACT: Build docker image and upload to a docker repository

=head1 SYNOPSIS

 # in dist.ini
 [Docker]
   image_name = foobar/my-image-name

=cut

use v5.20.0;
use strict;
use warnings;

use Moose;
use namespace::autoclean;

use File::pushd ();
use Dist::Zilla::Path;
use Dist::Zilla::Plugin::Docker::DockerClient;

# string formatter for formatting the tag
use String::Formatter method_stringf => {
  -as => '_format_string',
  codes => {
    d => sub { require DateTime;
               DateTime->now(time_zone => $_[0]->time_zone)
                       ->format_cldr($_[1] || 'dd-MMM-yyyy') },
    t => sub { $_[0]->zilla->is_trial ? (defined $_[1] ? $_[1] : '-TRIAL') : '' },
    v => sub { $_[0]->zilla->version },
    V => sub { my $v = $_[0]->zilla->version; $v =~ s/\Av//; $v },
  },
};

=head1 PARAMETERS

=head2 dockerfile

The name of the dockerfile used to build the image.  Default is C<Dockerfile>.

=cut

has dockerfile => (
  is       => 'ro',
  isa      => 'Str',
  required => 1,
  default  => 'Dockerfile'
);

=head2 image_name

The name of the docker image. For docker hub, this will be something like C<username/my-image>

=cut

has image_name => (is => 'ro', isa => 'Str', required => 1);

has tag => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  default => sub {
    my $self = shift;
    _format_string($self->tag_format, $self);
  },
);

=head2 tag_format

The format string for the image tag.  Default is C<v%V>.

=cut

has tag_format => (
  is            => 'ro',
  isa           => 'Str',
  default       => 'v%V',
  documentation => 'The tag format for the docker image. Defaults to v%V',
);

=head2 push_image

If true, runs C<docker push> at the end to push the image to the upstream repository.  Default is C<true>.

=cut

has push_image => (
  is            => 'ro',
  isa           => 'Bool',
  default       => 1,
  documentation => 'If true, push the docker image after building.  Default is true.'
);

=head2 time_zone

If using a date string in the L<tag_format>, the time zone used for computing the
current date.  Default is C<local>.

=cut

has time_zone => (
  is            => 'ro',
  isa           => 'Str',
  default       => 'local',
  documentation => 'Time zone for tag date format if using %d in the tag format'
);

has _docker_client => (
  is      => 'ro',
  isa     => 'Dist::Zilla::Plugin::Docker::DockerClient',
  lazy    => 1,
  default => sub {
    my $self = shift;

    Dist::Zilla::Plugin::Docker::DockerClient->new(
      docker_tag => join( ':', $self->image_name, $self->tag )
    );
  }
);

with 'Dist::Zilla::Role::Releaser';

sub release {
  my ($self, $tgz) = @_;

  $tgz = $tgz->absolute;

  my $build_dir = $self->zilla->root->child('.build');
  unless (-d $build_dir) {
    $build_dir->mkpath;
  }

  my $tmpdir = path( File::Temp::tempdir(DIR => $build_dir) );

  $self->log("Extracting $tgz to $tmpdir");

  my @files = $self->_extract_tgz($tgz, $tmpdir);

  $self->_build_docker_image($tmpdir->child($self->zilla->dist_basename));
}

sub _extract_tgz {
  my ($self, $tgz, $dir) = @_;

  require Archive::Tar;

  my @files = do {
    my $wd = File::pushd::pushd($dir);
    Archive::Tar->extract_archive($tgz->stringify);
  };

  unless (@files) {
    $self->log_fatal([ 'Failed to extract archive %s', Archive::Tar->error ]);
  }
}

sub _build_docker_image {
  my ($self, $distdir) = @_;

  $self->log("Building docker image for version ", $self->zilla->version);
  my $wd = File::pushd::pushd($distdir);

  unless (-f $self->dockerfile) {
    $self->log_fatal([ 'Docker build file (%s) not found in dist %s', $self->dockerfile, $wd ]);
  }

  $self->log([ 'Using dockerfile: %s', $self->dockerfile ]);

  my $docker_tag = join ':', $self->image_name, $self->tag;

  $self->_docker_client->build_image("$wd", $self->dockerfile);

  if ($self->push_image) {
    $self->_docker_client->push_image;
  }
}

__PACKAGE__->meta->make_immutable;
