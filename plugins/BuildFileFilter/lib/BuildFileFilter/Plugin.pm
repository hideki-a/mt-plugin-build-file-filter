package BuildFileFilter::Plugin;
use strict;
use CustomFields::Util qw( get_meta );
use MT::FileMgr;

# Note:
# $args{ArchiveType}
# ‘index’, ‘Individual’, ‘Page’, ‘Category’, ‘Daily’, ‘Monthly’, or ‘Weekly’

sub _build_file_filter {
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
            if ( MT->config('RebuildFilterDeleteFile')) {
                _delete_file($args{File});
            }

            return 0; # Don't publish.
        }
    }

    return 1;
}

# 下記プラグインを参考にしました
# https://github.com/alfasado/mt-plugin-rebuild-filter
# 
# MT::FileMgrの詳細は下記に記載されています
# http://www.sixapart.jp/movabletype/manual/object_reference/archives/mt_filemgr.html
sub _delete_file {
    my $file = shift;
    my $fmgr = MT::FileMgr->new('Local') or die MT::FileMgr->errstr;

    if ($fmgr->exists($file)) {
        $fmgr->delete($file);
    }
}

1;
