# NAME

Dist::Zilla::Plugin::Docker - Build docker image and upload to a docker repository

# VERSION

version 0.02

# SYNOPSIS

    # in dist.ini
    [Docker]
      image_name = foobar/my-image-name

# PARAMETERS

## dockerfile

The name of the dockerfile used to build the image.  Default is `Dockerfile`.

## image\_name

The name of the docker image. For docker hub, this will be something like `username/my-image`

## tag\_format

The format string for the image tag.  Default is `v%V`.

## push\_image

If true, runs `docker push` at the end to push the image to the upstream repository.  Default is `true`.

## time\_zone

If using a date string in the [tag\_format](https://metacpan.org/pod/tag_format), the time zone used for computing the
current date.  Default is `local`.

# SOURCE

The development version is on github at [https://https://github.com/mschout/dist-zilla-plugin-docker](https://https://github.com/mschout/dist-zilla-plugin-docker)
and may be cloned from [git://https://github.com/mschout/dist-zilla-plugin-docker.git](git://https://github.com/mschout/dist-zilla-plugin-docker.git)

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://github.com/mschout/dist-zilla-plugin-docker/issues](https://github.com/mschout/dist-zilla-plugin-docker/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHOR

Michael Schout <mschout@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Michael Schout.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
