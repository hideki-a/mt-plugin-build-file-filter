package BuildFileFilter::Plugin;
use strict;

sub build_file_filter {
    my ($cb, %args) = @_;

    if ($args{Blog}->id == 1) {
        if ($args{Entry}->authored_on + 0 < 20160101000000) {
            return 0; # Don't publish.
        } 
    }

    return 1;
}

1;
