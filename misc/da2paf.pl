#!/usr/bin/env perl

use strict;
use warnings;

die("Usage: da2paf.pl <(DBdump -rh reads.db) <(LAdump -cd aln.las)\n") if @ARGV < 1;

warn("Reading sequence lengths...\n");
my $fn = shift(@ARGV);
open(FH, $fn) || die;
my ($id, @len);
while (<FH>) {
	if (/^R\s(\d+)/) {
		$id = $1;
	} elsif (/^L\s\S+\s(\d+)\s(\d+)/) {
		$len[$id] = $2 - $1;
	}
}
close(FH);

warn("Converting mappings...\n");
my ($id0, $id1, $strand, $ab, $ae, $bb, $be);
while (<>) {
	if (/^P\s(\S+)\s(\S+)\s([nc])/) {
		$id0 = $1; $id1 = $2; $strand = $3 eq 'n'? '+' : '-';
	} elsif (/^C\s(\d+)\s(\d+)\s(\d+)\s(\d+)/) {
		$ab = $1, $ae = $2, $bb = $3, $be = $4;
	} elsif (/^D\s(\d+)/) {
		my $bl = $ae - $ab > $be - $bb? $ae - $ab : $be - $bb;
		my $ml = $bl - $1;
		if ($strand eq '+') {
			print join("\t", $id0, $len[$id0], $ab, $ae, '+', $id1, $len[$id1], $bb, $be, $ml, $bl, 255), "\n";
		} else {
			my $l = $len[$id1];
			print join("\t", $id0, $len[$id0], $ab, $ae, '-', $id1, $l, $l - $be, $l - $bb, $ml, $bl, 255), "\n";
		}
	}
}
