#!/usr/bin/perl -w
use strict;
use Cwd qw/getcwd/;
use File::Spec;

sub run {
	print STDERR join(" ",@_),"\n";
	return system(@_) == 0;
}
sub update_subrepo {
	my $dir = shift;
	my $scriptdir = shift;
	print STDERR "$dir not exist.\n" unless(-d $dir);
	chdir($dir) or die("$!\n");
	print STDERR "[$dir]\n";
	run('git','add','-A');
	run('sh',File::Spec->catfile($scriptdir, 'commit.sh'));
}

my %status = (
	modified=>[],
);
open FI,'-|','git status';
while(<FI>) {
	if(m/^#\s+([^:]+):\s+(.+)?\s+\([^\(\)]+\)\s*$/) {
		push @{$status{$1}},$2;
	}
}
#modified:   babebase (modified content, untracked content)
#	modified:   fp-afun (untracked content)
#	#	modified:   fp-default (untracked content)
#
close FI;

my $cwd = getcwd();
my $scriptdir = File::Spec->rel2abs($0,$cwd);#;#ARGV[0];
(undef,$scriptdir,undef) = File::Spec->splitpath($scriptdir);
foreach(@{$status{modified}}) {
	update_subrepo($_,$scriptdir,$cwd);
	chdir($cwd);
}
use Data::Dumper;print Data::Dumper->Dump([\%status],[qw/*status/]);

