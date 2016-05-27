package BuildFileFilter::Plugin;
use strict;
use CustomFields::Util qw( get_meta );

# Note:
# $args{ArchiveType}
# ‘index’, ‘Individual’, ‘Page’, ‘Category’, ‘Daily’, ‘Monthly’, or ‘Weekly’

sub build_file_filter {
    my ($cb, %args) = @_;

    # By Entry authored_on Data
    if ($args{Blog}->id == 1) {
        return 1 if $args{ArchiveType} ne 'Individual';

        if ($args{Entry}->authored_on + 0 < 20160101000000) {
            return 0; # Don't publish.
        }
    }

    # By MTEntryNoPublish Custom Field
    if ($args{Blog}->id == 10) {
        return 1 if $args{ArchiveType} ne 'Individual';

        my $meta = get_meta($args{Entry});

        if ($meta->{ entry_no_publish }) {
            return 0; # Don't publish.
        }
    }

    return 1;
}

1;
