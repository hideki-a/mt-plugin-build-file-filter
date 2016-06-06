package BuildFileFilter::Callbacks;
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
            if ( MT->config('RebuildFilterDeleteFile')) {
                _delete_file($args{File});
            }

            return 0; # Don't publish.
        }
    }

    # By MTEntryNoPublish Custom Field
    if ($args{Blog}->id == 10) {
        return 1 if $args{ArchiveType} ne 'Individual';

        my $meta = get_meta($args{Entry});

        if ($meta->{ entry_no_publish }) {    # $meta->{ customfield_basename }
            if ( MT->config('RebuildFilterDeleteFile')) {
                _delete_file($args{File});
            }

            return 0; # Don't publish.
        }
    }

    # By Monthly Archive PeriodStart
    if ($args{Blog}->id == 4) {
        return 1 if $args{ArchiveType} ne 'Monthly';

        my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = localtime(time);
        $year += 1900;
        $month += 1;

        if ($month < 12) {
            $month += 1;
        } else {
            $year += 1;
            $month = 1;
        }

        my $next_month = sprintf "%4d%02d01000000", $year, $month;

        if ($args{PeriodStart} + 0 >= $next_month) {
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
