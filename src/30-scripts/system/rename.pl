#!/usr/bin/perl

#line 18

use strict;

use Getopt::Long;
use Text::Abbrev;
use File::Basename;
use File::Glob ':bsd_glob';

my $VERSION = '1.9';

Getopt::Long::config(qw(bundling));
$Getopt::Long::prefix = '--';

my $ME = $0;
($ME = $0) =~ s!.*/!!;
$| = 1;

my $opt_dryrun          = 0;
my $opt_backup          = 0;
my $opt_force           = 0;
my $opt_interactive     = 0;
my $opt_verbose         = 0;
my $opt_help            = 0;
my $opt_stdin           = 1;
my $opt_version         = 0;
my $opt_linkonly        = 0;
my $opt_prefix          = '';
my $opt_suffix          = '';
my $opt_basename_prefix = '';
my $opt_vcm             = $ENV{RENAME_VERSION_CONTROL}
                        || $ENV{VERSION_CONTROL}
                        || 'existing';

sub VCM_SIMPLE   { 0 }
sub VCM_TEST     { 1 }
sub VCM_NUMBERED { 2 }

my $vcm;

sub error {
    my($ERROR) = @_;
    print "$ME: $ERROR\n";
    print "Try `$ME --help' for more information.\n";
    exit 1;
}

{
    local $SIG{__WARN__} = sub {
	if ($_[0] =~ /^Unknown option: (\S+)/) {
	    error("unrecognized option `--$1'");
	}
        else {
	    print @_;
	}
    };
    GetOptions(
	       'b|backup'             => \$opt_backup,
               'B|prefix=s'           => \$opt_prefix,
	       'f|force'              => \$opt_force,
	       'h|help'               => \$opt_help,
	       'i|interactive'        => \$opt_interactive,
               'l|link-only'          => \$opt_linkonly,
	       'n|just-print|dry-run' => \$opt_dryrun,
               's|stdin!'             => \$opt_stdin,
	       'version'              => \$opt_version,
	       'v|verbose'            => \$opt_verbose,
	       'V|version-control=s'  => \$opt_vcm,
               'Y|basename-prefix=s'  => \$opt_basename_prefix,
	       'z|S|suffix=s'         => \$opt_suffix,
	      );
}

if ($opt_version) {
    print "$ME $VERSION\n";
    exit 0;
}

if ($opt_help) {
    print<<HELP;
Usage: $ME [OPTION]... PERLEXPR FILE...
Rename FILE(s) using PERLEXPR on each filename.

  -b, --backup                  make backup before removal
  -B, --prefix=SUFFIX           set backup filename prefix
  -f, --force                   remove existing destinations, never prompt
  -i, --interactive             prompt before overwrite
  -l, --link-only               link file instead of reame
  -n, --just-print, --dry-run   don't rename, implies --verbose
  -v, --verbose                 explain what is being done
  -V, --version-control=METHOD  override the usual version control
  -Y, --basename-prefix=PREFIX  set backup filename basename prefix
  -z, -S, --suffix=SUFFIX       set backup filename suffix
      --help                    display this help and exit
      --version                 output version information and exit

The backup suffix is ~, unless set with SIMPLE_BACKUP_SUFFIX.  The
version control may be set with VERSION_CONTROL, values are:

  numbered, t     make numbered backups
  existing, nil   numbered if numbered backups exist, simple otherwise
  simple, never   always make simple backups

Report bugs to pederst\@cpan.org
HELP
    exit 0; #'
}

if ($opt_backup) {
    if ($opt_prefix || $opt_basename_prefix || $opt_suffix) {
        $vcm = VCM_SIMPLE;
    }
    else {
        $vcm = ${abbrev qw(nil existing t numbered never simple)}{$opt_vcm};
        error("invalid version contol type `$opt_vcm'") unless $vcm;
        $vcm = ${{ nil      => VCM_TEST,
	           existing => VCM_TEST,
	           t        => VCM_NUMBERED,
                   numbered => VCM_NUMBERED,
	           never    => VCM_SIMPLE,
	           simple   => VCM_SIMPLE,
	        }}{$vcm};
    }

    $opt_suffix ||= $ENV{SIMPLE_BACKUP_SUFFIX} || '~';
}

my $op = shift
    or error('missing arguments');

if (!@ARGV) {
    if ($opt_stdin) {
        @ARGV = <STDIN>;
        chomp(@ARGV);
    }
    else {
       exit;
    }
}

for (@ARGV) {
    my $was = $_;
    {
        no strict;
        eval $op;
    }
    die $@ if $@;
    next if $was eq $_;

    if (-e $_) {
        unless ($opt_force) {
	    if (! -w && -t) {
		printf "%s: overwrite `%s', overriding mode 0%03o? ",
                       $ME, $_, (stat _)[2]&0777;
		next unless <STDIN> =~ /^y/i;
	    }
            elsif ($opt_interactive) {
		print "$ME: replace `$_'? ";
		next unless <STDIN> =~ /^y/i;
	    }
	}
	if ($opt_backup) {
            my $old;
	    if ($vcm == VCM_SIMPLE) {
                if (m,^(.*/)?(.*),) {
		    $old = "$opt_prefix$1$opt_basename_prefix$2$opt_suffix";
                }
	    }
            else {
		($old) = sort {($b=~/~(\d+)~$/)[0] <=> ($a=~/~(\d+)~$/)[0]} bsd_glob "$_.~*~";
		$old =~ s/~(\d+)~$/'~'.($1+1).'~'/e;
		if ($vcm == VCM_TEST) {
                    unless ($old) {
                        if (m,^(.*/)?(.*),) {
	  	            $old = "$opt_prefix$1$opt_basename_prefix$2$opt_suffix";
                        }
                    }
		}
                elsif ($vcm == VCM_NUMBERED) {
		    $old ||= "$_.~1~";
		}
	    }
            print "backup: $_ -> $old\n" if $opt_verbose && $opt_dryrun;

            unless ($opt_dryrun) {
                if ($old =~ m,/,) {
                    my $dir = File::Basename::dirname($old);
                    unless (-d $dir) {
                        if ($opt_dryrun) {
                            print "mkdir: $dir\n" if $opt_verbose;
                        }
                        else {
                            mkpath($dir) || next;
                        }
                    }
                }
                unless (rename($_,$old)) {
                    warn "$ME: cannot create `$old': $!\n";
                    next;
                }
            }
        }
    }

    print "$was ", $opt_linkonly ? "=" : '-', "> $_\n"
       if $opt_verbose || $opt_dryrun;

    if (m,/,) {
        my $dir = File::Basename::dirname($_);
        unless (-d $dir) {
            if ($opt_dryrun) {
                print "mkdir: $dir\n" if $opt_verbose;
            }
            else {
                mkpath($dir) || next;
            }
         }
    }

    unless ($opt_dryrun) {
        if ($opt_linkonly) {
	    link($was,$_) || warn "$ME: cannot create `$_': $!\n";
        }
        else {
            rename($was,$_) || warn "$ME: cannot create `$_': $!\n";
	}
    }
}

sub mkpath {
    my($path) = @_;
    $path .= '/' if $^O eq 'os2' and $path =~ /^\w:\z/s; # feature of CRT
    # Logic wants Unix paths, so go with the flow.
    if ($^O eq 'VMS') {
        next if $path eq '/';
        $path = VMS::Filespec::unixify($path);
        if ($path =~ m:^(/[^/]+)/?\z:) {
            $path = $1.'/000000';
        }
    }
    return 1 if -d $path;
    my $parent = File::Basename::dirname($path);
    unless (-d $parent or $path eq $parent) {
        mkpath($parent) || return;
    }
    #print "mkdir: $path\n" if $opt_verbose;
    unless (mkdir($path, 0777)) {
        unless (-d $path) {
            warn "$ME: cannot mkdir `$path': $!\n";
            return;
        }
    }
    return 1;
}

__END__

=head1 NAME

rename - renames multiple files

=head1 SYNOPSIS

B<rename>
[B<-bfilnv>]
[B<-B> I<prefix>]
[B<-S> I<suffix>]
[B<-V> I<method>]
[B<-Y> I<prefix>]
[B<-z> I<suffix>]
[B<--backup>]
[B<--basename-prefix=>I<prefix>]
[B<--dry-run>]
[B<--force>]
[B<--help>]
[B<--no-stdin>]
[B<--interactive>]
[B<--just-print>]
[B<--link-only>]
[B<--prefix=>I<prefix>]
[B<--suffix=>I<suffix>]
[B<--verbose>]
[B<--version-control=>I<method>]
[B<--version>]
I<perlexpr>
[F<files>]...

=head1 DESCRIPTION

I<rename> renames the filenames supplied according to the rule specified
as the first argument.  The argument is a Perl expression which is
expected to modify the $_ string for at least some of the filenames
specified.  If a given filename is not modified by the expression, it
will not be renamed.  If no filenames are given on the command line,
filenames will be read via standard input.

If a destination file is unwritable, the standard input is a tty, and
the B<-f> or B<--force> option is not given, mv prompts the user for
whether to overwrite the file.  If the response does not begin with `y'
or `Y', the file is skipped.

=head1 OPTIONS

=over 4

=item B<-b>, B<--backup>

Make backup files.  That is, when about to overwrite a file, rename the
original instead of removing it.  See the B<-V> or B<--version-control>
option fo details about how backup file names are determined.

=item B<-B> I<prefix>, B<--prefix=>I<prefix>

Use the B<simple> method to determine backup file names (see the B<-V>
I<method> or B<--version-control=>I<method> option), and prepend
I<prefix> to a file name when generating its backup file name.

=item B<-f>, B<--force>

Remove existing destination files and never prompt the user.

=item B<-h>, B<--help>

Print a summary of options and exit.

=item B<-no-stdin>

Disable reading of filenames from STDIN. Us it when your shell has nullglob
enabled to make sure rename doesn't wait for input.

=item B<-i>, B<--interactive>

Prompt whether to overwrite each destination file that already exists.
If the response does not begin with `y' or `Y', the file is skipped.

=item B<-l>, B<--link-only>

Link files to the new names instead of renaming them. This will keep the
original files.

=item B<-n>, B<--just-print>, B<--dry-run>

Do everything but the actual renaming, insted just print the name of
each file that would be renamed. When used together with B<--verbose>,
also print names of backups (which may or may not be correct depending
on previous renaming).

=item B<-v>, B<--verbose>

Print the name of each file before renaming it.

=item B<-V> I<method>, B<--version-control=>I<method>

Use I<method> to determine backup file names.  The method can also be
given by the B<RENAME_VERSION_CONTROL> (or if that's not set, the
B<VERSION_CONTROL>) environment variable, which is overridden by this
option.  This option does not affect wheter backup files are made; it
affects only the name of any backup files that are made.

The value of I<method> is like the GNU Emacs `version-control' variable;
B<rename> also recognize synonyms that are more descriptive.  The valid
values are (unique abbreviations are accepted):

=over

=item B<existing> or B<nil>

Make numbered backups of files that already have them, otherwise simple
backups. This is the default.

=item B<numbered> or B<t>

Make numbered backups.  The numbered backup file name for I<F> is
B<I<F>.~I<N>~> where I<N> is the version number.

=item B<simple> or B<never>

Make simple backups.  The B<-B> or B<--prefix>, B<-Y> or
B<--basename-prefix>, and B<-z> or B<--suffix> options specify the
simple backup file name.  If none of these options are given, then a
simple backup suffix is used, either the value of
B<SIMPLE_BACKUP_SUFFIX> environment variable if set, or B<~> otherwise.

=back

=item B<--version>

Print version information on standard output then exit successfully.

=item B<-Y> I<prefix>, B<--basename-prefix=>I<prefix>

Use the B<simple> method to determine backup file names (see the B<-V>
I<method> or B<--version-control=>I<method> option), and prefix
I<prefix> to the basename of a file name when generating its backup file
name. For example, with B<-Y .del/> the simple backup file name for
B<a/b/foo> is B<a/b/.del/foo>.

=item B<-z> I<suffix>, B<-S> I<suffix>, B<--suffix=>I<suffix>

Use the B<simple> method to determine backup file names (see the B<-V>
I<method> or B<--version-control=>I<method> option), and append
I<suffix> to a file name when generating its backup file name.

=back

=head1 EXAMPLES

To rename all files matching *.bak to strip the extension, you might
say

    rename 's/\e.bak$//' *.bak

To translate uppercase names to lower, you'd use

    rename 'y/A-Z/a-z/' *

More examples:

    rename 's/\.flip$/.flop/'       # rename *.flip to *.flop
    rename s/flip/flop/             # rename *flip* to *flop*
    rename 's/^s\.(.*)/$1.X/'       # switch sccs filenames around
    rename 's/$/.orig/ */*.[ch]'    # add .orig to source files in */
    rename 'y/A-Z/a-z/'             # lowercase all filenames in .
    rename 'y/A-Z/a-z/ if -B'       # same, but just binaries!
or even
    rename chop *~                  # restore all ~ backup files

=head1 ENVIRONMENT

Two environment variables are used, B<SIMPLE_BACKUP_SUFFIX> and
B<VERSION_CONTROL>.  See L</OPTIONS>.

=head1 SEE ALSO

mv(1) and perl(1)

=head1 DIAGNOSTICS

If you give an invalid Perl expression you'll get a syntax error.

=head1 AUTHOR

Peder Stray <pederst@cpan.org>, original script from Larry Wall.

=cut
